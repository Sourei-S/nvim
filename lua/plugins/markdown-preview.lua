-- マークダウンをブラウザでプレビューする
return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = "cd app && npm install",
  keys = {
    { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "マークダウンプレビューを開閉" },
  },
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }

    -- WSL環境ではWindows側のブラウザでプレビューを開く
    -- (WSL2はlocalhostのポートをWindows側へ自動転送するため、そのままURLを開けば良い)
    vim.cmd([[
      function! OpenMarkdownPreviewInWindows(url)
        execute "silent !/mnt/c/Windows/System32/cmd.exe /c start " . a:url
      endfunction
    ]])
    vim.g.mkdp_browserfunc = "OpenMarkdownPreviewInWindows"
  end,
}
