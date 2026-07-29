-- 保存時などにリンターを実行して問題箇所を診断表示する
return {
  -- リンター本体をmason経由で自動インストールする
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = "mason-org/mason.nvim",
    opts = {
      -- ruff(Python)はmasonだとpython3-venvが必要で失敗するため、uvで導入済み
      -- (再インストールする場合: uv tool install ruff)
      ensure_installed = {
        "eslint_d", -- JavaScript/TypeScript
        "shellcheck", -- シェルスクリプト
        "markdownlint", -- Markdown
        "stylua", -- Luaフォーマッタ
        "prettierd", -- JS/TS/JSON/CSS/Markdownフォーマッタ
        "prettier", -- prettierdが動かない環境向けのフォールバック(conform側のstop_after_firstと対応)
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")

      -- ファイルタイプごとに使うリンター
      lint.linters_by_ft = {
        python = { "ruff" },
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        markdown = { "markdownlint" },
      }

      -- ESLintは設定ファイルがないプロジェクトで実行するとエラーになるため、有無を確認する
      local function has_eslint_config()
        return vim.fs.find({
          ".eslintrc",
          ".eslintrc.js",
          ".eslintrc.cjs",
          ".eslintrc.json",
          "eslint.config.js",
          "eslint.config.mjs",
          "eslint.config.cjs",
        }, { upward = true, path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) })[1] ~= nil
      end

      -- ファイルを開いたとき・保存したとき・挿入モードを抜けたときに実行する
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
        callback = function()
          local names = lint.linters_by_ft[vim.bo.filetype] or {}
          if vim.tbl_contains(names, "eslint_d") and not has_eslint_config() then
            return
          end
          -- ignore_errors: リンター未インストール時にエラー表示しない
          lint.try_lint(nil, { ignore_errors = true })
        end,
      })
    end,
  },
}
