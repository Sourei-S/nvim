-- ファジーファインダー(ファイル名・文字列・バッファなどをあいまい検索する)
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- ソートをC実装に置き換えて高速化する(要: make, cc)
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    -- vim.ui.select(テンプレート選択など)をtelescopeのドロップダウンにする
    "nvim-telescope/telescope-ui-select.nvim",
  },
  cmd = "Telescope",
  -- 遅延ロードでもvim.ui.selectが最初から効くよう、初回呼び出し時に
  -- telescope本体をロードしてから本物のvim.ui.select(ui-select拡張が
  -- 差し替えたもの)へ委譲する
  init = function()
    vim.ui.select = function(...)
      require("lazy").load({ plugins = { "telescope.nvim" } })
      return vim.ui.select(...)
    end
  end,
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "ファイル名で検索" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "ファイル内の文字列を検索(要: ripgrep)" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "最近開いたファイル" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "開いているバッファ一覧" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "ヘルプを検索" },
  },
  opts = {},
  config = function(_, opts)
    local telescope = require("telescope")
    -- 画像ファイルはsnacks.imageでプレビューし、それ以外は従来のプレビューを使う
    local image_exts = { png = true, jpg = true, jpeg = true, gif = true, bmp = true, webp = true }
    local default_maker = require("telescope.previewers").buffer_previewer_maker
    opts.defaults = {
      buffer_previewer_maker = function(filepath, bufnr, maker_opts)
        local ext = vim.fn.fnamemodify(filepath, ":e"):lower()
        if image_exts[ext] then
          require("snacks.image.buf").attach(bufnr, { src = filepath })
        else
          default_maker(filepath, bufnr, maker_opts)
        end
      end,
    }
    opts.extensions = {
      ["ui-select"] = require("telescope.themes").get_dropdown(),
    }
    telescope.setup(opts)
    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")
  end,
}
