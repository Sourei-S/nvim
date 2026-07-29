-- Gitの差分やファイル履歴をサイドバイサイドで表示する
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git差分を表示" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "現在ファイルのGit履歴" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Git差分表示を閉じる" },
  },
  opts = {},
}
