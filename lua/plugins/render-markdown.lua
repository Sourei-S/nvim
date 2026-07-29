-- マークダウンをnvimのバッファ内で装飾表示する(Tree-sitterのmarkdownパーサーを使用)
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown" },
  keys = {
    { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", ft = "markdown", desc = "マークダウン装飾表示を切り替え" },
  },
  opts = {},
}
