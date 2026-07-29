-- 開いているバッファを画面上部にタブのように一覧表示する
return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  keys = {
    { "<leader>x", "<cmd>bdelete<cr>", desc = "現在のバッファを閉じる" },
  },
  opts = {
    options = {
      -- 閉じるボタンなどにマウス操作も使える
      diagnostics = "nvim_lsp",
    },
  },
}
