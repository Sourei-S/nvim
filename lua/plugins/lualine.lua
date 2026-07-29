-- 画面下部のステータスラインに現在のモード(NORMAL/INSERTなど)を色付きで表示する
return {
  "nvim-lualine/lualine.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  init = function()
    -- モードはlualineが表示するので、標準の「-- INSERT --」表示は消す
    vim.opt.showmode = false
  end,
  opts = {
    options = {
      theme = "dracula-nvim", -- カラースキームと合わせる
    },
    sections = {
      lualine_c = {
        "filename",
        {
          -- コード上の現在位置(クラス→関数など)をnvim-navicから取得して表示する
          function()
            return require("nvim-navic").get_location()
          end,
          cond = function()
            return package.loaded["nvim-navic"] ~= nil and require("nvim-navic").is_available()
          end,
        },
      },
    },
  },
}
