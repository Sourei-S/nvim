-- oilバッファへ挿入するファイル構成テンプレート集。
-- テンプレートを増やすときは M.templates に { name, lines } を1項目足す。
-- lines の末尾が "/" ならディレクトリ、それ以外は空ファイルとして :w で作成される
local M = {}

M.templates = {
  {
    name = "agentプロジェクト構成",
    lines = {
      ".agents/",
      ".claude/",
      ".codex/",
      "docs/",
      ".gitignore",
    },
  },
}

-- テンプレートの行をoilバッファのカーソル行の下に挿入し、挿入した行数を返す。
-- 表示中のディレクトリに既に存在するエントリは、oilの保存処理が
-- 重複行で混乱しないようスキップする
function M.insert(template, bufnr)
  bufnr = bufnr or 0
  local dir = require("oil").get_current_dir(bufnr)
  if not dir then
    return 0
  end

  local lines = vim.tbl_filter(function(entry)
    return not vim.uv.fs_stat(dir .. entry:gsub("/$", ""))
  end, template.lines)

  if #lines == 0 then
    vim.notify("テンプレートの内容はすべて既に存在します", vim.log.levels.INFO)
    return 0
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)
  return #lines
end

-- テンプレートを選んで現在のoilバッファに挿入する
function M.pick()
  vim.ui.select(M.templates, {
    prompt = "テンプレートを選択",
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if choice then
      M.insert(choice, 0)
    end
  end)
end

return M
