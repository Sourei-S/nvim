-- HTMLをw3mでテキスト化してフロートウィンドウに表示する
-- (render-markdown.nvimのバッファ内装飾に相当するHTML版)
local M = {}

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

return M
