-- ファジーファインダー(ファイル名・文字列・バッファなどをあいまい検索する)
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- ソートをC実装に置き換えて高速化する(要: make, cc)
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "ファイル名で検索" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "ファイル内の文字列を検索(要: ripgrep)" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "最近開いたファイル" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "開いているバッファ一覧" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "ヘルプを検索" },
  },
  opts = {},
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    telescope.load_extension("fzf")
  end,
}
