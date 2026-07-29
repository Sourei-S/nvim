-- Tree-sitterによるシンタックスハイライト
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate", -- プラグイン更新時にパーサーも更新する
  lazy = false,
  config = function()
    -- インストールしておく言語パーサー
    local languages = {
      "bash",
      "css",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "toml",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    }
    require("nvim-treesitter").install(languages)

    -- パーサーがある言語のバッファでハイライトを有効にする
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
