-- 彩度の高いビビッドな配色のカラースキーム
return {
  "Mofiqul/dracula.nvim",
  lazy = false,
  priority = 1000, -- 他のプラグインより先に読み込んで配色を適用する
  opts = {
    transparent_bg = true, -- 背景透過設定と合わせる
  },
  config = function(_, opts)
    require("dracula").setup(opts)
    vim.cmd.colorscheme("dracula")
    -- デフォルトの列ハイライトは背景より暗く見分けがつかないため、行と同じ色に揃える
    vim.api.nvim_set_hl(0, "CursorColumn", { link = "CursorLine" })
  end,
}
