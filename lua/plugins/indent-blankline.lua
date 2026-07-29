-- インデントの深さを縦線で可視化する
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    exclude = {
      -- スタート画面とファイラには表示しない
      filetypes = { "alpha", "oil" },
    },
  },
}
