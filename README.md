# Neovim 設定

WSL2 (Ubuntu) 上の Neovim 用の個人設定。プラグイン管理は [lazy.nvim](https://github.com/folke/lazy.nvim)、カラースキームは dracula。設定ファイルのコメントはすべて日本語で書いている。

## 必要環境

| 種類 | 内容 |
|---|---|
| 必須 | Neovim 0.12+ / git / curl |
| フォント | Nerd Font(アイコン表示に使用。ターミナル側に設定) |
| LSP・lint | Node.js + npm(pyright / ts_ls / bashls / eslint_d などの実体) |
| 検索 | ripgrep(Telescope の live_grep) |
| ビルド | make / cc(telescope-fzf-native のビルド) |
| 展開 | unzip(mason が zip 配布ツール(stylua 等)を展開する際に使用) |
| クリップボード | win32yank(Windows クリップボードとの共有) |
| Git | lazygit(`<Space>gg` で使用) |
| Python lint | uv(`uv tool install ruff` で ruff を導入。mason だと python3-venv が必要で失敗するため) |

WSL 前提の設定(Windows ブラウザでのマークダウンプレビュー、explorer.exe 経由のファイルオープン等)を含む。WSL 以外の環境では該当機能は要調整。

## セットアップ

```sh
git clone <このリポジトリ> ~/.config/nvim
nvim  # 初回起動時に lazy.nvim・プラグイン・LSPサーバー・リンター・フォーマッタが自動インストールされる
uv tool install ruff  # Python リンターのみ手動
```

## ディレクトリ構成

```
init.lua                    -- エディタ基本設定・キーマップ・自動リロード・ハイライト調整
keybindings.md              -- キーバインド一覧(oil のデフォルトキー含む)
lua/config/lazy.lua         -- lazy.nvim のブートストラップ
lua/config/open-external.lua -- Office/PDF/画像等を OS 既定アプリで開く独自スクリプト
lua/config/oil-templates.lua -- oil バッファへのテンプレート一括挿入(定型のファイル構成を定義)
lua/plugins/*.lua           -- プラグイン設定(1プラグイン1ファイル)
docs/superpowers/specs/     -- 変更時の設計メモ
```

## エディタ基本設定 (init.lua)

- **リーダーキー**: `<Space>`(ローカルリーダーは `\`)
- **行番号の2列表示**: 左に絶対行番号、右に相対行番号を並べて表示(相対は2始まり)
- **アンドゥ履歴の永続化**: `undofile` で nvim を閉じても履歴から復元できる
- **検索**: 大文字小文字を無視(`ignorecase`)、ただし検索語に大文字を含むときだけ区別(`smartcase`)
- **画面分割**: 右・下に開く(`splitright` / `splitbelow`)。カーソル上下に常に5行の余白(`scrolloff`)
- **記号列の常時表示**: `signcolumn=yes` で診断・git 記号による画面の横揺れを防止
- **クリップボード共有**: ヤンク・削除を Windows クリップボードと共有(win32yank 経由)
- **外部変更の自動リロード**: Claude Code や git がファイルを書き換えたら自動で読み直す。フォーカスイベントに加えて2秒間隔のタイマーでも `checktime` を実行し、リロード時は通知を出す
- **背景透過**: `Normal` 等の背景を `none` にしてターミナルの透過を活かす(カラースキーム再適用後も維持)
- **Visual ハイライト調整**: dracula 標準の選択色は暗くて見えないため `#6272a4` に上書き
- **キーマップ**: `Shift+H` / `Shift+L` でバッファ切り替え、`jj` でインサートモード脱出

## プラグイン一覧

### 見た目

| プラグイン | 役割 |
|---|---|
| [dracula.nvim](https://github.com/Mofiqul/dracula.nvim) | カラースキーム(背景透過設定と連動) |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | ステータスライン。navic のパンくず表示も組み込み |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | バッファをタブ風に一覧表示。LSP のエラー数も表示 |
| [alpha-nvim](https://github.com/goolord/alpha-nvim) | スタート画面(よく使う操作のメニュー・起動時間表示) |
| [noice.nvim](https://github.com/folke/noice.nvim) | コマンドライン(`:` `/`)を画面中央のポップアップ化 |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | インデントガイド線 |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | `<Space>` 押下後に続きのキー一覧をポップアップ表示 |

### コーディング支援

| プラグイン | 役割 |
|---|---|
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | シンタックスハイライト(bash/lua/python/ts/markdown 等14言語) |
| [mason.nvim](https://github.com/mason-org/mason.nvim) + [mason-lspconfig](https://github.com/mason-org/mason-lspconfig.nvim) + [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP。lua_ls / pyright / ts_ls / bashls を自動インストール |
| [nvim-navic](https://github.com/SmiteshP/nvim-navic) | コード上の現在位置(クラス→関数)をステータスラインに表示 |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint) + [mason-tool-installer](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | 保存時などに自動 lint(下表) |
| [blink.cmp](https://github.com/saghen/blink.cmp) + [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | 自動補完(LSP・スニペット・バッファ・パス)。コマンドライン補完も担当 |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | コード整形。`<Space>cf` で手動実行(保存時の自動整形はしない、下表) |
| [mini.pairs](https://github.com/nvim-mini/mini.pairs) | 括弧・クォートの閉じ側を自動入力 |

| 言語 | リンター | 備考 |
|---|---|---|
| Python | ruff | uv で導入(mason 対象外) |
| JavaScript / TypeScript | eslint_d | ESLint 設定ファイルがあるプロジェクトのみ実行 |
| シェルスクリプト | shellcheck | |
| Markdown | markdownlint | |

| 言語 | フォーマッタ | 備考 |
|---|---|---|
| Lua | stylua | |
| Python | ruff format | uv で導入した ruff を使用 |
| JS / TS / JSON / CSS / Markdown | prettierd | 使えない環境では prettier にフォールバック |

### 検索・ファイル操作

| プラグイン | 役割 |
|---|---|
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | あいまい検索(ファイル名・全文・バッファ等)。fzf-native で高速化。ui-select 拡張で `vim.ui.select`(テンプレート選択など)もドロップダウン化 |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | バッファ型ファイラ。ディレクトリをバッファとして編集し、ファイル操作できる。ドットファイル常時表示。`<Space>t` でテンプレート一括挿入(下記の独自スクリプト) |

### Git

| プラグイン | 役割 |
|---|---|
| [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) | Neovim 内から lazygit を開く |
| [diffview.nvim](https://github.com/sindrets/diffview.nvim) | 差分・ファイル履歴のサイドバイサイド表示 |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | git 差分を行番号横に表示し、hunk 単位のステージ・取り消し・プレビューを提供 |

### Markdown・その他

| プラグイン | 役割 |
|---|---|
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Windows 側ブラウザでプレビュー(WSL 対応の独自設定) |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | バッファ内でマークダウンを装飾表示 |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | フローティングターミナル |

## 主なキーマップ

詳細(oil バッファ内の操作キー含む)は [keybindings.md](keybindings.md) を参照。

| キー | 動作 |
|---|---|
| `<Space>ff` / `fg` / `fr` / `fb` / `fh` | ファイル名 / 全文 / 最近 / バッファ / ヘルプ検索 (Telescope) |
| `-` / `<Space>e` | 親ディレクトリをファイラ (oil) で開く |
| `Shift+H` / `Shift+L` / `<Space>x` | 前後のバッファへ / バッファを閉じる |
| `gd` / `K` / `grr` | 定義ジャンプ / ホバー / 参照一覧 (LSP) |
| `<Space>rn` / `<Space>ca` / `[d` `]d` | リネーム / コードアクション / 診断へ移動 (LSP) |
| `<Space>gg` | LazyGit |
| `<Space>gd` / `gh` / `gq` | Git 差分 / ファイル履歴 / 差分を閉じる (Diffview) |
| `]h` / `[h` / `<Space>hs` `hr` `hp` `hb` | hunk 移動 / ステージ・取り消し・プレビュー・blame (gitsigns) |
| `<Space>cf` | コードを整形 (conform) |
| `Ctrl+y` / `Ctrl+n` `Ctrl+p` / `Ctrl+Space` / `Tab` | 補完の確定 / 候補移動 / 手動表示 / スニペット内移動 (blink.cmp) |
| `Ctrl+\` | フローティングターミナル |
| `<Space>t` | テンプレートからファイル構成を挿入 (oil バッファ内のみ) |
| `<Space>mp` / `<Space>mr` | ブラウザプレビュー / バッファ内装飾 (markdown) |
| `jj` | インサートモードを抜ける |

## 独自スクリプト: oil テンプレート一括挿入

`lua/config/oil-templates.lua`。oil のバッファで `<Space>t` を押すと、あらかじめ定義したファイル構成(テンプレート)を Telescope のドロップダウンから選択でき、カーソル行の下に一括挿入される。そのまま `:w` すればディレクトリ・ファイルがまとめて作成される(既存の名前は挿入時にスキップ)。

使い方:

1. oil でテンプレートを展開したいディレクトリを開く
2. `<Space>t` → 一覧から選択(`j`/`k` で移動、`Enter` で確定)
3. `:w` で一括作成

### テンプレートの追加方法

`lua/config/oil-templates.lua` の `M.templates` に1項目追加するだけで、選択肢に自動で並ぶ。

```lua
M.templates = {
  {
    name = "agentプロジェクト構成",  -- 選択肢に表示される名前
    lines = {                        -- 挿入される行(末尾 / でディレクトリ)
      ".agents/",
      ".claude/",
      ".codex/",
      "docs/",
      ".gitignore",
    },
  },
  -- ここに { name = "...", lines = { ... } } を追加する
}
```

## 独自スクリプト: 外部アプリでのファイルオープン

`lua/config/open-external.lua`。Office 文書・PDF・画像・音声・動画などを nvim で開こうとすると、バッファに読み込む代わりに OS 既定のアプリ(WSL では explorer.exe 経由で Windows 側の関連付けアプリ)で開く。対象拡張子はファイル冒頭の `extensions` で増減できる。
