vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 行番号を絶対・相対の2列で表示する(左: 絶対 / 右: 相対、カーソル行は相対側を空欄に)
vim.opt.number = true
vim.opt.relativenumber = true
-- 相対番号は1ではなく2から始める
vim.opt.statuscolumn = "%s%=%{printf('%3d', v:lnum)} %{v:relnum == 0 ? '   ' : printf('%3d', v:relnum + 1)} "

-- ヤンク・削除をWindowsのクリップボードと共有する(win32yank経由)
vim.opt.clipboard = "unnamedplus"

-- アンドゥ履歴をファイルに保存し、nvimを閉じても復元できるようにする
vim.opt.undofile = true

-- 検索は大文字小文字を無視する(検索語に大文字を含めたときだけ区別する)
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 画面分割は右・下に開く
vim.opt.splitright = true
vim.opt.splitbelow = true

-- カーソルの上下に常に5行の余白を確保する
vim.opt.scrolloff = 5

-- 診断・git記号の列を常に表示する(記号が出た瞬間に画面が横にずれるのを防ぐ)
vim.opt.signcolumn = "yes"

-- カーソルのある行・列をハイライト表示する
vim.opt.cursorline = true
vim.opt.cursorcolumn = true

-- バッファの切り替え(H/Lの画面上端・下端への移動を上書きしている)
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "前のバッファへ" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "次のバッファへ" })

-- jjでインサートモードを抜ける
vim.keymap.set("i", "jj", "<Esc>", { desc = "ノーマルモードに戻る" })

-- nvimを終了する
vim.keymap.set("n", "<leader>q", "<cmd>qa<cr>", { desc = "nvimを終了" })

-- 外部(Claude・git等)でファイルが変更されたら自動で読み直す
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermClose", "TermLeave" }, {
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- フォーカスが当たっていなくても外部変更を拾えるよう、2秒ごとに定期チェックする
local checktime_timer = vim.uv.new_timer()
checktime_timer:start(
  2000,
  2000,
  vim.schedule_wrap(function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("silent! checktime")
    end
  end)
)

-- 自動リロードされたときに通知を出す
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function(args)
    vim.notify("外部で変更されたため再読み込みしました: " .. vim.fn.fnamemodify(args.file, ":t"), vim.log.levels.INFO)
  end,
})

require("config.lazy")

-- Office・PDF・画像などnvimで扱えないファイルをOS既定のアプリで開く
require("config.open-external")

-- HTMLをlive-serverでブラウザにライブプレビューする(<leader>mp)
require("config.html-preview")

-- 背景を透過にする(カラースキーム適用後にも維持されるようautocmdで設定)
local function set_transparent_bg()
  local groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "SignColumn",
    "EndOfBuffer",
  }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
end

-- 選択(Visualモード)のハイライトが暗くて見えにくいので明るめの色に上書きする
local function set_visual_hl()
  vim.api.nvim_set_hl(0, "Visual", { bg = "#6272a4" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    set_transparent_bg()
    set_visual_hl()
  end,
})
set_transparent_bg()
set_visual_hl()
