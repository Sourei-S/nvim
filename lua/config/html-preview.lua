-- HTMLをlive-serverで配信し、ブラウザでライブリロードプレビューする
-- (markdown-preview.nvimのブラウザプレビューに相当するHTML版)
local M = {}

-- 起点ポートから順に試し、最初に空いていたポートを返す
function M.find_port(start)
  for port = start, start + 20 do
    local server = vim.uv.new_tcp()
    -- libuvがSO_REUSEADDRを立てるため、bindは使用中のポートでも成功してしまう。
    -- listenまで試して初めて使用中を検出できる
    local ok = server:bind("127.0.0.1", port)
    if ok then
      ok = server:listen(16, function() end)
    end
    server:close()
    if ok then
      return port
    end
  end
  return nil
end

-- 配信ルートとURL上のパスを決める。
-- ../css/style.css のような相対参照を壊さないよう、原則cwdをルートにする
function M.resolve(path, cwd)
  local abs = vim.fn.fnamemodify(path, ":p")
  local rel = vim.fs.relpath(cwd, abs)
  if rel then
    return cwd, rel, true
  end
  -- cwd外のファイルは配信できないので、そのファイルのディレクトリで代替する
  return vim.fn.fnamemodify(abs, ":h"), vim.fn.fnamemodify(abs, ":t"), false
end

return M
