# Neovim キーバインド一覧

## リーダーキー

| キー | 設定 | 定義場所 |
|---|---|---|
| `<Space>` | `<leader>` (リーダーキー) | `init.lua` |
| `\` | `<localleader>` (ローカルリーダーキー) | `init.lua` |

## カスタムキーバインド

| キー | モード | 動作 | 定義場所 |
|---|---|---|---|
| `-` | Normal | 親ディレクトリをファイラ (oil) で開く | `lua/plugins/oil.lua` |
| `<Space>e` | Normal | 親ディレクトリをファイラ (oil) で開く | `lua/plugins/oil.lua` |
| `Shift+H` | Normal | 前のバッファへ切り替え | `init.lua` |
| `Shift+L` | Normal | 次のバッファへ切り替え | `init.lua` |
| `<Space>x` | Normal | 現在のバッファを閉じる | `lua/plugins/bufferline.lua` |
| `jj` | Insert | ノーマルモードに戻る | `init.lua` |
| `<Space>mp` | Normal (markdownのみ) | マークダウンプレビューをブラウザで開閉 | `lua/plugins/markdown-preview.lua` |
| `<Space>mr` | Normal (markdownのみ) | バッファ内のマークダウン装飾表示を切り替え | `lua/plugins/render-markdown.lua` |
| `<Space>gg` | Normal | LazyGit を開く | `lua/plugins/lazygit.lua` |
| `<Space>t` | Normal (oilバッファのみ) | テンプレートからファイル構成を挿入(選択後 :w で一括作成) | `lua/plugins/oil.lua` |
| `Ctrl+\` | Normal / Terminal | フローティングターミナルを開閉(ターミナル内からも閉じられる) | `lua/plugins/toggleterm.lua` |
| `<Space>cf` | Normal / Visual | コードを整形(該当フォーマッタが無い言語はLSPの整形機能にフォールバック) | `lua/plugins/conform.lua` |
| `]h` | Normal | 次の変更箇所(hunk)へ移動 | `lua/plugins/gitsigns.lua` |
| `[h` | Normal | 前の変更箇所(hunk)へ移動 | `lua/plugins/gitsigns.lua` |
| `<Space>hs` | Normal | 変更箇所をステージ(再実行で取り消し) | `lua/plugins/gitsigns.lua` |
| `<Space>hr` | Normal | 変更箇所を元に戻す | `lua/plugins/gitsigns.lua` |
| `<Space>hp` | Normal | 変更内容をプレビュー | `lua/plugins/gitsigns.lua` |
| `<Space>hb` | Normal | この行のblameを表示 | `lua/plugins/gitsigns.lua` |

## 補完(blink.cmp)ポップアップ表示中の操作(プラグインデフォルト)

入力中に補完候補が表示されている状態で使えるキーです(`keymap = { preset = "default" }` の既定値)。

| キー | 動作 |
|---|---|
| `<C-y>` | 選択中の候補を確定 |
| `<C-n>` | 次の候補へ移動 |
| `<C-p>` | 前の候補へ移動 |
| `<C-space>` | 候補を手動で表示 |
| `<Tab>` | スニペット内のジャンプ位置へ移動 |

## oil バッファ内の操作(プラグインデフォルト)

oil のバッファにフォーカスがある状態で使えるキーです。`g?` で全キーのヘルプが表示されます。

### 開く・閉じる・移動

| キー | 動作 |
|---|---|
| `<CR>` | ファイルを開く / ディレクトリに入る |
| `-` | 親ディレクトリへ移動 |
| `_` | カレントディレクトリ(cwd)を開く |
| `<C-s>` | 垂直分割で開く |
| `<C-h>` | 水平分割で開く |
| `<C-t>` | 新しいタブで開く |
| `<C-p>` | プレビューの切り替え |
| `<C-c>` | oil バッファを閉じる |
| `` ` `` | 開いているディレクトリに cwd を変更 |
| `g?` | キーバインドのヘルプを表示 |

### ファイル操作

ファイルの作成・リネーム・削除は通常のテキスト編集で行い、`:w` で確定します(確認プロンプトあり)。

| 操作 | 動作 |
|---|---|
| 行を追加して名前を入力 | ファイルを新規作成(末尾に `/` でディレクトリ) |
| 行のファイル名を書き換え | リネーム |
| `dd` で行を削除 | ファイルを削除 |
| `dd` → 別ディレクトリで `p` | ファイルを移動 |
| `yy` → 別ディレクトリで `p` | ファイルをコピー |

### 表示

| キー | 動作 |
|---|---|
| `g.` | 隠しファイルの表示切り替え ※設定でドットファイルは常に表示 |
| `gs` | ソート順の変更 |
| `<C-l>` | 表示を更新 |

## プラグイン管理

| コマンド | 動作 |
|---|---|
| `:Lazy` | lazy.nvim の管理画面を開く |
| `:TSUpdate` | Tree-sitter パーサーを更新 |
| `:MarkdownPreviewToggle` | マークダウンプレビューをブラウザで開閉 |
| `:RenderMarkdown toggle` | バッファ内のマークダウン装飾表示を切り替え |
| `:LazyGit` | LazyGit を開く |
| `:ToggleTerm` | フローティングターミナルを開閉 |
