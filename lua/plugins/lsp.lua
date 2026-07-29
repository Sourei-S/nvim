-- LSP(言語サーバー): 定義ジャンプ・リネーム・診断などのコード解析機能
return {
  -- LSPサーバーや外部ツールを:Masonで管理・自動インストールする
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  -- masonでインストールしたLSPサーバーを自動で有効化する
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      -- 自動インストールするLSPサーバー
      ensure_installed = {
        "lua_ls", -- Lua
        "pyright", -- Python
        "ts_ls", -- JavaScript/TypeScript
        "bashls", -- bash
      },
    },
    config = function(_, opts)
      -- lua_lsにNeovim設定用のグローバル変数vimを認識させる
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      require("mason-lspconfig").setup(opts)

      -- 診断メッセージを行末に表示する
      vim.diagnostic.config({ virtual_text = true })

      -- LSPが有効になったバッファにキーマップを追加する
      -- (標準のキーマップもそのまま使える:
      --  K=ホバー表示 / grn=リネーム / gra=コードアクション / grr=参照一覧 / [d ]d=診断へ移動)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "定義へジャンプ")
          map("<leader>rn", vim.lsp.buf.rename, "シンボル名を一括変更")
          map("<leader>ca", vim.lsp.buf.code_action, "コードアクション")
        end,
      })
    end,
  },
}
