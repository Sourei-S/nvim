-- フローティングウィンドウで一時的なターミナルを開閉する
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>t", "<cmd>ToggleTerm<cr>", desc = "ターミナルを開閉" },
  },
  opts = {
    direction = "float",
    -- ターミナル内(ターミナルモード・挿入モード)からも Ctrl+\ で閉じられる
    open_mapping = [[<C-\>]],
    float_opts = {
      border = "rounded",
    },
  },
}
