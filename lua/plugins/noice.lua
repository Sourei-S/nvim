-- コマンドライン(:や/)を画面中央のフローティングウィンドウに表示する
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    -- コマンドライン補完メニューはblink.cmpが描画するため、noice側の実装は無効にする
    popupmenu = { enabled = false },
    views = {
      -- コマンドライン入力欄を画面の上下左右中央に配置する
      cmdline_popup = {
        position = {
          row = "50%",
          col = "50%",
        },
        size = {
          width = 60,
          height = "auto",
        },
      },
      -- コマンド補完メニューは入力欄のすぐ下に出す
      popupmenu = {
        relative = "editor",
        position = {
          row = "62%",
          col = "50%",
        },
        size = {
          width = 60,
          height = 10,
        },
        border = {
          style = "rounded",
          padding = { 0, 1 },
        },
      },
    },
  },
}
