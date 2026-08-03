-- WSL2 + Windows側ターミナル(WezTerm等)でsnacks.imageの画像描画を成立させるための補正。
-- 実機WSL2+WezTermで確認した2つの問題に対処する:
--  1. snacksは既定で画像を t=f(ファイルパス参照)でターミナルに渡すが、
--     Windows側プロセスのターミナルはWSL内のパス(/home/...)を読めず何も描画されない
--  2. WSLのptyはTIOCGWINSZでピクセル寸法を返さない(0になる)が、snacksはcol/rowしか
--     検証しないためセル寸法0のままサイズ計算がnanに汚染され、配置要求が c=nan になる
--     (フロートが細い縦長の枠になる症状の原因)
local M = {}

-- セル寸法が0の場合にsnacksのフォールバックと同じ既定値(9x18)で補う
---@param s table Snacks.image.terminal.size() の戻り値
function M.fix_size(s)
  if s.cell_width == 0 or s.cell_height == 0 then
    s.cell_width, s.cell_height = 9, 18
    s.width = s.columns * s.cell_width
    s.height = s.rows * s.cell_height
    s.scale = s.cell_width / 8
  end
  return s
end

-- snacksロード後(setup直後)に呼ぶ。WSL以外では何もしない
function M.setup()
  if vim.fn.has("wsl") ~= 1 then
    return
  end
  -- リモート(ssh)扱いにすると画像データが t=d で直接転送され、パス問題を回避できる
  vim.env.SNACKS_SSH = "1"
  local Terminal = require("snacks.image.terminal")
  local size = Terminal.size
  Terminal.size = function()
    return M.fix_size(size())
  end
end

return M
