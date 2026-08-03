-- 画像プレビュー(snacks.nvimのimageモジュールのみ使用)
-- WezTermはunicode placeholders未対応のため、Markdown内の画像は
-- カーソルを乗せたときのフロート表示になる(kitty/ghosttyなら自動でインライン表示)
-- 注: 画像ファイルの直接:editは既存のopen-external.lua(OS既定アプリで開く)が担当する。
-- snacksはoil/telescopeのプレビューとMarkdownフロートに使う
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = true, -- 対応ターミナルではインライン表示(WezTermでは自動で無効化)
        float = true, -- 非対応ターミナルではカーソル位置にフロート表示
        max_width = 80,
        max_height = 40,
      },
    },
    -- 既存プラグイン(telescope/noice/alpha等)と衝突しないよう他モジュールは使わない
    -- (snacksの他モジュールはデフォルト無効だが、意図を明示するため主要なものを列挙)
    bigfile = { enabled = false },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    notifier = { enabled = false },
    picker = { enabled = false },
    quickfile = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  },
  config = function(_, opts)
    require("snacks").setup(opts)
    -- WSL2ではWindows側ターミナルへのパス参照転送とセル寸法取得が機能しないため補正する
    require("config.snacks-image-wsl").setup()
  end,
}
