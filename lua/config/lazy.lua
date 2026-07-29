local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- lazy.nvimが未導入なら、GitHubからstable版を取得する
if vim.fn.isdirectory(lazy_path) == 0 then
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazy_path,
  })

  if vim.v.shell_error ~= 0 then
    error("lazy.nvimの取得に失敗しました:\n" .. result)
  end
end

-- Neovimがlazy.nvimを読み込めるようにする
vim.opt.runtimepath:prepend(lazy_path)

-- lua/plugins内の設定ファイルを読み込む
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
})
