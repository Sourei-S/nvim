-- フローティングウィンドウで一時的なターミナルを開閉する
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    -- 右辺なしのエントリは遅延読み込みのトリガーとしてだけ働き、
    -- 読み込み後は本体の open_mapping (<C-\>) がノーマル/ターミナル両モードの開閉を担う
    { [[<C-\>]], mode = { "n", "t" }, desc = "ターミナルを開閉" },
  },
  opts = {
    direction = "float",
    -- ターミナル内(ターミナルモード・挿入モード)からも Ctrl+\ で閉じられる
    open_mapping = [[<C-\>]],
    float_opts = {
      border = "rounded",
    },
  },
}
