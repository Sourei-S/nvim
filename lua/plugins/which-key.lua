-- <leader>などを押したまま少し待つと、続けて押せるキーの一覧をポップアップ表示する
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      -- プレフィックスキーのグループ名
      { "<leader>f", group = "検索(Telescope)" },
      { "<leader>g", group = "Git" },
      { "<leader>m", group = "プレビュー" },
    },
  },
}
