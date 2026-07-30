-- バッファ型ファイラ。ディレクトリを通常のバッファとして開き、
-- ファイル名の編集(dd/p/ccなど)でリネーム・作成・削除できる
return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- default_file_explorer を機能させるため起動時にロードする
  lazy = false,
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "親ディレクトリをファイラで開く" },
    { "<leader>e", "<cmd>Oil<cr>", desc = "親ディレクトリをファイラで開く" },
  },
  opts = {
    -- netrw を置き換え、`nvim <dir>` でも oil が開くようにする
    default_file_explorer = true,
    -- 既定のキーマップは維持され、ここに書いたものだけ追加・上書きされる
    keymaps = {
      ["<leader>t"] = {
        callback = function()
          require("config.oil-templates").pick()
        end,
        mode = "n",
        desc = "テンプレートからファイル構成を挿入",
      },
    },
    view_options = {
      -- ドットファイルも表示する
      show_hidden = true,
    },
  },
}
