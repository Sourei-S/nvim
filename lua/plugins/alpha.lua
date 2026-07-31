-- スタート画面(引数なしで起動したときのダッシュボード)
return {
  "goolord/alpha-nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "MaximilianLloyd/ascii.nvim", -- ヘッダー用ASCIIアート集
    "MunifTanjim/nui.nvim", -- ascii.nvimのプレビュー機能に必要
  },
  event = "VimEnter",
  opts = function()
    local dashboard = require("alpha.themes.dashboard")

    -- ヘッダー: ascii.nvimのAAを表示する
    -- 他のAAは :lua require("ascii").preview() で一覧・プレビューできる
    dashboard.section.header.val = require("ascii").art.text.neovim.sharp

    -- キー1つで実行できるメニュー
    dashboard.section.buttons.val = {
      dashboard.button("e", "  新規ファイル", "<cmd>enew<cr>"),
      dashboard.button("f", "  ファイル名で検索", "<cmd>Telescope find_files<cr>"),
      dashboard.button("s", "  文字列で検索", "<cmd>Telescope live_grep<cr>"),
      dashboard.button("r", "  最近開いたファイル", "<cmd>Telescope oldfiles<cr>"),
      dashboard.button("t", "  ファイラ", "<cmd>Oil<cr>"),
      dashboard.button("g", "  LazyGit", "<cmd>LazyGit<cr>"),
      dashboard.button("l", "󰒲  プラグイン管理", "<cmd>Lazy<cr>"),
      dashboard.button("q", "  終了", "<cmd>qa<cr>"),
    }

    -- コンテンツ全体が画面の上下中央に来るよう、上部の余白を動的に計算する
    -- (関数にしておくと再描画のたびに評価され、ウィンドウのリサイズにも追従する)
    dashboard.config.layout[1].val = function()
      local content_height = #dashboard.section.header.val
        + 2 -- ヘッダーとメニューの間の余白
        + #dashboard.section.buttons.val * 2 - 1 -- メニュー(1行ごとに空行1つ)
        + 1 -- フッター
      return math.max(0, math.floor((vim.fn.winheight(0) - content_height) / 2))
    end

    return dashboard.opts
  end,
  config = function(_, opts)
    require("alpha").setup(opts)

    -- 最後のバッファを閉じたとき、空バッファの代わりにダッシュボードへ戻る
    vim.api.nvim_create_autocmd("BufDelete", {
      callback = function(args)
        -- 削除中のバッファを除き、表示する意味のあるバッファが残っているか数える
        -- (無名でも未保存の変更があるバッファは「残っている」扱いにして隠さない)
        local remaining = vim.tbl_filter(function(buf)
          return buf ~= args.buf
            and vim.bo[buf].buflisted
            and (vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].modified)
        end, vim.api.nvim_list_bufs())

        if #remaining == 0 then
          -- bdelete完了後でないとウィンドウの差し替えができないため遅延実行する
          vim.schedule(function()
            -- 削除後に表示されているのが「空の無名通常バッファ」のときだけダッシュボードへ戻す。
            -- oilなどのunlistedな特殊バッファへ切り替えた直後もBufDeleteが発火するため、
            -- filetypeだけの判定ではそれらのウィンドウを乗っ取ってしまう
            if
              vim.bo.buftype == ""
              and vim.bo.filetype == ""
              and vim.api.nvim_buf_get_name(0) == ""
              and not vim.bo.modified
            then
              require("alpha").start(false)
            end
          end)
        end
      end,
    })

    -- 起動完了後、プラグイン数と起動時間をフッターに表示する
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        require("alpha.themes.dashboard").section.footer.val = string.format(
          "⚡ %d/%d plugins loaded in %.2fms",
          stats.loaded,
          stats.count,
          stats.startuptime
        )
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
