-- oil用の画像フロートプレビュー。oil標準プレビューは実ファイルのバッファを読み込み、
-- open-external.luaのBufReadCmd(OS既定アプリで開く+バッファ削除)に奪われるため、
-- スクラッチバッファにsnacks.imageをattachしたフロートウィンドウで代替する
local M = {}

local state = { win = nil }

-- 開いているプレビューを閉じる。閉じたらtrueを返す
function M.close()
  local win = state.win
  state.win = nil
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    return true
  end
  return false
end

-- 画像をフロートでプレビューする。開いた状態で呼ぶと閉じる(トグル)
function M.toggle(path)
  if M.close() then
    return
  end
  local buf = vim.api.nvim_create_buf(false, true)
  state.win = vim.api.nvim_open_win(buf, false, {
    relative = "cursor",
    row = 1,
    col = 2,
    width = math.min(80, math.floor(vim.o.columns * 0.6)),
    height = math.min(40, math.floor(vim.o.lines * 0.6)),
    style = "minimal",
    border = "rounded",
    title = vim.fn.fnamemodify(path, ":t"),
  })
  require("snacks.image.buf").attach(buf, { src = path })
  -- カーソル移動かoilバッファから離れたら自動で閉じる
  vim.api.nvim_create_autocmd({ "CursorMoved", "BufLeave" }, {
    buffer = vim.api.nvim_get_current_buf(),
    once = true,
    callback = M.close,
  })
end

return M
