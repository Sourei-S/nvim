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
    -- 削除を含まない単純な編集(作成5件以下・移動/コピー各1件以下)は
    -- :w 時の確認フロートを出さず即実行する。確認フロートはy/oでしか
    -- 確定できずEnterが効かないため、テンプレート一括作成の流れを妨げる
    skip_confirm_for_simple_edits = true,
    -- 既定のキーマップは維持され、ここに書いたものだけ追加・上書きされる
    keymaps = {
      ["<leader>t"] = {
        callback = function()
          require("config.oil-templates").pick()
        end,
        mode = "n",
        desc = "テンプレートからファイル構成を挿入",
      },
      ["<C-p>"] = {
        callback = function()
          local oil = require("oil")
          local entry = oil.get_cursor_entry()
          local dir = oil.get_current_dir()
          -- open-external.luaが外部アプリで開いてしまう画像拡張子は
          -- フロート+snacks.imageでプレビューする(それ以外は標準プレビュー)
          local image_exts = {
            png = true, jpg = true, jpeg = true, gif = true, bmp = true,
            webp = true, tif = true, tiff = true, heic = true, avif = true,
          }
          local ext = entry and entry.type == "file" and entry.name:match("%.([^.]+)$")
          if dir and ext and image_exts[ext:lower()] then
            require("config.oil-image-preview").toggle(dir .. entry.name)
          else
            require("oil.actions").preview.callback()
          end
        end,
        mode = "n",
        desc = "プレビュー(画像はフロートでnvim内表示)",
      },
    },
    view_options = {
      -- ドットファイルも表示する
      show_hidden = true,
    },
  },
}
