-- コード上の現在位置(クラス→関数など)をパンくずリストで表示する(LSPの情報を利用)
-- 表示はlualineのステータスライン(ファイル名の隣)に組み込んでいる
return {
  "SmiteshP/nvim-navic",
  event = "LspAttach", -- LSPに接続したタイミングで読み込む
  opts = {
    -- 対応するLSPサーバーが起動したら自動で接続する
    lsp = { auto_attach = true },
    highlight = true,
  },
}
