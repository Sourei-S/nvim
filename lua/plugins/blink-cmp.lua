-- 入力中にLSP・スニペット・バッファ・パスの候補を自動表示する補完エンジン
return {
  "saghen/blink.cmp",
  -- リリース版に固定し、ビルド済みの高速マッチャー(Rust製)を自動ダウンロードする
  version = "1.*",
  dependencies = {
    -- 各言語の定型スニペット集(スニペット本体はNeovim標準のvim.snippetで展開)
    "rafamadriz/friendly-snippets",
  },
  event = { "InsertEnter", "CmdlineEnter" },
  opts = {
    -- <C-y>=確定 / <C-n><C-p>=候補移動 / <C-space>=手動で候補表示 / <Tab>=スニペット内移動
    keymap = { preset = "default" },
    completion = {
      -- 選択中の候補の説明ウィンドウを自動表示する
      documentation = { auto_show = true },
    },
    -- 関数の引数入力中にシグネチャを表示する
    signature = { enabled = true },
  },
}
