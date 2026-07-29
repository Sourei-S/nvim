-- git差分(追加・変更・削除)を行番号の横に表示し、hunk単位の操作を提供する
-- (lazygit=リポジトリ全体の操作 / diffview=差分の閲覧 / gitsigns=バッファ内の即時操作、と役割分担)
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end
      map("n", "]h", function() gs.nav_hunk("next") end, "次の変更箇所へ")
      map("n", "[h", function() gs.nav_hunk("prev") end, "前の変更箇所へ")
      map("n", "<leader>hs", gs.stage_hunk, "変更箇所をステージ(再実行で取り消し)")
      map("n", "<leader>hr", gs.reset_hunk, "変更箇所を元に戻す")
      map("n", "<leader>hp", gs.preview_hunk, "変更内容をプレビュー")
      map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "この行のblameを表示")
    end,
  },
}
