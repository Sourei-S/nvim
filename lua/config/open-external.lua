-- nvimで直接扱えないファイルを、バッファに読み込む代わりにOS既定のアプリで開く
-- 対象を増減したい場合はextensionsを編集する

-- 対象の拡張子(小文字で書いておけば大文字のファイル名にもマッチする)
local extensions = {
  -- Office系
  "doc", "docx", "docm", "xls", "xlsx", "xlsm", "ppt", "pptx", "pptm",
  "odt", "ods", "odp", "rtf", "vsd", "vsdx", "msg",
  -- PDF・PostScript系
  "pdf", "ps", "eps",
  -- デザイン系
  "ai", "psd",
  -- 画像
  "png", "jpg", "jpeg", "gif", "bmp", "webp", "ico", "tif", "tiff", "heic", "avif",
  -- 音声・動画
  "mp3", "wav", "m4a", "flac", "ogg", "mp4", "mov", "avi", "mkv", "wmv", "webm",
}

-- OS既定のアプリでファイルを開く
local function open_external(path)
  if vim.fn.has("wsl") == 1 then
    -- WSLではWindows側のパスへ変換し、explorer.exe経由で関連付けアプリを起動する
    local winpath = vim.trim(vim.system({ "wslpath", "-w", path }, { text = true }):wait().stdout)
    vim.system({ "explorer.exe", winpath }, { detach = true })
  else
    -- WSL以外はNeovim標準のオープナー(open/xdg-open等)に任せる
    local _, err = vim.ui.open(path)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end

-- "pdf"を"*.[pP][dD][fF]"のような大文字・小文字を区別しないautocmdパターンへ変換する
local function to_pattern(ext)
  local pattern = ext:gsub("%a", function(char)
    return "[" .. char:lower() .. char:upper() .. "]"
  end)
  return "*." .. pattern
end

-- 標準のzipプラグインがOffice系拡張子(実体はzip)のBufReadCmdを登録していて二重処理になるため、
-- 対象拡張子ぶんだけ解除する
local function clear_zip_plugin_autocmds()
  for _, ext in ipairs(extensions) do
    pcall(vim.api.nvim_clear_autocmds, {
      event = "BufReadCmd",
      pattern = "*." .. ext,
      group = "zip",
    })
  end
end

-- zipプラグインはrequire("config.lazy")の時点で読み込み済みなので、この場で解除できる
clear_zip_plugin_autocmds()
-- 読み込み順が変わった場合の保険として、起動完了後にも解除する
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("open_external_clear_zip", { clear = true }),
  callback = clear_zip_plugin_autocmds,
})

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = vim.api.nvim_create_augroup("open_external", { clear = true }),
  pattern = vim.tbl_map(to_pattern, extensions),
  desc = "対象ファイルをOS既定のアプリで開く",
  callback = function(ev)
    local path = vim.fn.fnamemodify(ev.match, ":p")

    if vim.uv.fs_stat(path) then
      open_external(path)
      vim.notify("OS既定のアプリで開きました: " .. vim.fn.fnamemodify(path, ":t"))
    else
      vim.notify("ファイルが存在しません: " .. path, vim.log.levels.WARN)
    end

    -- 読み込みを肩代わりしたため、残った空バッファは閉じる(autocmd実行中は消せないので遅延実行)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        vim.api.nvim_buf_delete(ev.buf, { force = true })
      end
    end)
  end,
})
