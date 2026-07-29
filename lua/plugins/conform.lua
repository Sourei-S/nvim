-- コード整形(フォーマッタ)。<leader>cfで手動実行する(保存時の自動整形はしない)
return {
  "stevearc/conform.nvim",
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function()
        -- 該当フォーマッタが無い言語ではLSPの整形機能にフォールバックする
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "コードを整形",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      -- ruffはuv管理(lint.lua参照)。整形はruff format相当のサブコマンドを使う
      python = { "ruff_format" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },
    },
  },
}
