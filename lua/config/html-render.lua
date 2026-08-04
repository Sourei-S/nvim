-- HTMLをw3mでテキスト化してフロートウィンドウに表示する
-- (render-markdown.nvimのバッファ内装飾に相当するHTML版)
local M = {}

local state = { win = nil }

-- HTMLの行配列をw3mで整形する。失敗時は nil とエラーメッセージを返す
function M.render(lines, cols)
  if vim.fn.executable("w3m") ~= 1 then
    return nil, "w3mが見つかりません。sudo apt install w3m を実行してください"
  end
  local res = vim.system({
    "w3m",
    "-dump",
    -- stdin渡しでは内容の種別を判定できないため、HTMLであることを明示する
    "-T", "text/html",
    "-I", "UTF-8",
    "-O", "UTF-8",
    -- 折り返し位置を表示幅に一致させる
    "-cols", tostring(cols),
  }, { stdin = table.concat(lines, "\n"), text = true }):wait()

  if res.code ~= 0 then
    return nil, "w3mの実行に失敗しました: " .. (res.stderr or "")
  end
  return vim.split(res.stdout or "", "\n")
end

-- 開いているフロートを閉じる。閉じたらtrueを返す
function M.close()
  local win = state.win
  state.win = nil
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    return true
  end
  return false
end

-- 現在のバッファをw3mで整形してフロート表示する。開いた状態で呼ぶと閉じる(トグル)
function M.toggle()
  if M.close() then
    return
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  -- 保存前の変更も反映させるため、ファイルではなくバッファの内容を渡す
  local lines, err = M.render(vim.api.nvim_buf_get_lines(0, 0, -1, false), width)
  if not lines then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  local name = vim.fn.expand("%:t")
  local buf = vim.api.nvim_create_buf(false, true)
  -- ウィンドウを閉じた時にスクラッチバッファも破棄し、孤児バッファの蓄積を防ぐ
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "htmlrender"

  -- q/<Esc>を効かせるためフォーカスを移す(第2引数がtrue)
  state.win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = name ~= "" and name or "HTML",
  })

  vim.keymap.set("n", "q", M.close, { buffer = buf, desc = "プレビューを閉じる" })
  vim.keymap.set("n", "<Esc>", M.close, { buffer = buf, desc = "プレビューを閉じる" })
  -- フロート表示中に<leader>mrを再度押しても閉じられるようにする(フォーカスがフロートに移るため)
  vim.keymap.set("n", "<leader>mr", M.toggle, { buffer = buf, desc = "プレビューを閉じる" })
end

vim.api.nvim_create_user_command("HtmlRender", function()
  M.toggle()
end, { desc = "HTMLをw3mで整形してフロート表示" })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("html_render", { clear = true }),
  pattern = "html",
  desc = "htmlバッファに<leader>mrを割り当てる",
  callback = function(ev)
    vim.keymap.set("n", "<leader>mr", M.toggle, {
      buffer = ev.buf,
      desc = "HTMLをw3mで整形してフロート表示",
    })
  end,
})

return M
