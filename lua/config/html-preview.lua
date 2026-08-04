-- HTMLをlive-serverで配信し、ブラウザでライブリロードプレビューする
-- (markdown-preview.nvimのブラウザプレビューに相当するHTML版)
local M = {}

local state = { proc = nil, port = nil, root = nil, cancel_wait = nil, file = nil }

-- 起点ポートから順に試し、最初に空いていたポートを返す
function M.find_port(start)
  for port = start, start + 20 do
    local server = vim.uv.new_tcp()
    -- libuvがSO_REUSEADDRを立てるため、bindは使用中のポートでも成功してしまう。
    -- listenまで試して初めて使用中を検出できる
    local ok = server:bind("127.0.0.1", port)
    if ok then
      ok = server:listen(16, function() end)
    end
    server:close()
    if ok then
      return port
    end
  end
  return nil
end

-- 配信ルートとURL上のパスを決める。
-- ../css/style.css のような相対参照を壊さないよう、原則cwdをルートにする
function M.resolve(path, cwd)
  local abs = vim.fn.fnamemodify(path, ":p")
  local rel = vim.fs.relpath(cwd, abs)
  if rel then
    return cwd, rel, true
  end
  -- cwd外のファイルは配信できないので、そのファイルのディレクトリで代替する
  return vim.fn.fnamemodify(abs, ":h"), vim.fn.fnamemodify(abs, ":t"), false
end

-- live-serverの起動コマンドを組み立てる。
-- グローバル導入があればそれを使い、無ければnpx経由にフォールバックする
function M.server_cmd(port, root)
  -- live-serverはデフォルトで0.0.0.0にbindし、作業ディレクトリを全ネットワークインターフェースへ
  -- 公開してしまう(インストール済みコードのoptions.host || '0.0.0.0'で確認済み)。
  -- find_portはlocalhost限定で空きを確認しているので、待受先もlocalhostへ明示的に絞る
  local args = { "--port=" .. port, "--host=127.0.0.1", "--no-browser", "--quiet", root }
  if vim.fn.executable("live-server") == 1 then
    return vim.list_extend({ "live-server" }, args), false
  end
  if vim.fn.executable("npx") == 1 then
    return vim.list_extend({ "npx", "--yes", "live-server" }, args), true
  end
  return nil, false
end

-- ポートと相対パスからプレビューURLを組み立てる。
-- パスは vim.uri_encode(rel, "rfc3986") でパーセントエンコードする。空白・#・?・日本語などの
-- 非ASCII文字を含むファイル名(この環境ではむしろ普通)でもURLが壊れないようにするため。
-- rfc3986のパターンは"/"を許可文字として温存するので、パス区切りはそのまま残る
-- (実機確認: vim.uri_encode("a b/日本語 file.html", "rfc3986")
--   == "a%20b/%e6%97%a5%e6%9c%ac%e8%aa%9e%20file.html")
function M.build_url(port, rel)
  return ("http://127.0.0.1:%d/%s"):format(port, vim.uri_encode(rel, "rfc3986"))
end

-- URLをブラウザで開く。テストから差し替えられるようフィールドとして持つ
function M.open_url(url)
  if vim.fn.has("wsl") == 1 then
    -- WSL2はlocalhostのポートをWindows側へ自動転送するため、URLをそのまま渡せば良い。
    -- 第4引数の空文字列は削除しないこと: cmd.exeのstartは最初の引用符付き引数を
    -- ウィンドウタイトルとして解釈する。URLに空白を含むとlibuvがそれを引用符で囲むため、
    -- タイトル引数を省略するとstartがURL自体をタイトルと誤認し、ブラウザが開かなくなる
    vim.system({ "cmd.exe", "/c", "start", "", url }, { detach = true })
  else
    local _, err = vim.ui.open(url)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end

-- ポートがlistenを始めるまで待つ。開いたらon_ready、時間切れならon_timeoutを呼ぶ。
-- 呼び出し側が待機を打ち切れるようcancel()を返す。
-- タイマーのstop/closeは内部のfinished一つで管理し、finish()とcancel()の
-- どちらから来ても一度しか実行されないようにしてある(cancel()は何度呼んでも安全)。
-- 実サーバーを使わずにcancelの冪等性をテストできるようM._wait_until_listeningとして公開している
function M._wait_until_listening(port, timeout_ms, on_ready, on_timeout)
  local timer = vim.uv.new_timer()
  local waited = 0
  local finished = false

  local function finish(callback)
    if finished then
      return
    end
    finished = true
    timer:stop()
    timer:close()
    if callback then
      vim.schedule(callback)
    end
  end

  timer:start(200, 200, function()
    waited = waited + 200
    local client = vim.uv.new_tcp()
    client:connect("127.0.0.1", port, function(err)
      client:close()
      if not err then
        finish(on_ready)
      elseif waited >= timeout_ms then
        finish(on_timeout)
      end
    end)
  end)

  return function()
    finish(nil)
  end
end

-- procが「今も現在進行中の起動」である場合だけcallbackを実行するようラップする。
-- start()を呼び直す/stop()するとstate.procが入れ替わるため、
-- 古いstart()が仕掛けたタイマーの結果が後から届いても、
-- 別物になった現在のサーバーへ誤って干渉しないためのガード。
-- 純粋な関数なのでM.open_url同様、テストのためにも公開している
function M._guarded(proc, callback)
  return function(...)
    if state.proc == proc then
      callback(...)
    end
  end
end

-- テスト専用: 実際にstart()を経由せずstate.procだけを差し替える。
-- state自体は非公開のままにして、kill/タイマー解除の不変条件を外から壊せないようにする
function M._set_proc_for_test(proc)
  state.proc = proc
end

-- テスト専用: 実際にstart()を経由せずstate.cancel_waitだけを差し替える
function M._set_cancel_wait_for_test(cancel)
  state.cancel_wait = cancel
end

-- サーバーを停止する。停止したらtrueを返す
function M.stop()
  local proc = state.proc

  -- 起動待ちがあれば打ち切る。M._guardedのおかげで結果自体は無害化されるが、
  -- 打ち切らずに放置すると最大15秒間ポーリングし続ける無駄が残る
  if state.cancel_wait then
    state.cancel_wait()
    state.cancel_wait = nil
  end

  state.proc, state.port, state.root, state.file = nil, nil, nil, nil
  if proc then
    -- npxはlive-server本体をnodeの孫プロセスとして起動するため、
    -- 親(npx)にSIGTERMを送るだけでは孫まで届かず生き残ってしまう(実機で確認済み)。
    -- start()でdetach=trueにしてこのprocをプロセスグループのリーダーにしてあるので、
    -- 負のpidを指定してグループ全体にシグナルを送る。失敗時のみ個体killへ後退する
    local ok, killed = pcall(vim.uv.kill, -proc.pid, "sigterm")
    if not (ok and killed) then
      proc:kill("sigterm")
    end
    return true
  end
  return false
end

-- 現在のバッファのHTMLをブラウザでプレビューする
function M.start()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("名前の付いていないバッファはプレビューできません", vim.log.levels.WARN)
    return
  end
  local abs = vim.fn.fnamemodify(path, ":p")

  local root, rel, inside = M.resolve(path, vim.fn.getcwd())
  if not inside then
    vim.notify("カレントディレクトリ外のため、配信ルートを " .. root .. " にします", vim.log.levels.WARN)
  end

  -- 同じルートで起動済みなら、サーバーは使い回してブラウザだけ開き直す
  if state.proc and state.root == root then
    state.file = abs
    M.open_url(M.build_url(state.port, rel))
    return
  end
  M.stop()

  local port = M.find_port(5501)
  if not port then
    vim.notify("空きポートが見つかりませんでした(5501〜5521)", vim.log.levels.ERROR)
    return
  end

  local cmd, via_npx = M.server_cmd(port, root)
  if not cmd then
    vim.notify("live-serverもnpxも見つかりません。Node.jsを導入してください", vim.log.levels.ERROR)
    return
  end
  if via_npx then
    vim.notify("npx経由でlive-serverを起動します(初回は10秒ほどかかります)。npm i -g live-server で高速化できます")
  end

  local errors = {}
  -- on_exitの中で自分自身(proc)を識別する必要があるため、先にlocalだけ宣言しておく。
  -- 代入はvim.system()の戻り値を待つが、on_exitはlibuvのイベントループを介して
  -- 非同期に呼ばれるので、代入前にon_exitが動くことはない
  local proc
  -- detach=trueでプロセスグループのリーダーにしておく(M.stopでのグループkillに必要)
  proc = vim.system(cmd, {
    text = true,
    detach = true,
    stderr = function(_, data)
      if data then
        table.insert(errors, data)
      end
    end,
  }, function(res)
    -- Finding3対応: on_exitが空だと、live-serverが即死しても状態がstate.procに残ったままになり、
    -- (1) 使い回し判定が死んだポートへURLを開いてしまう (2) toggleが「起動中」と誤認して
    -- 「停止しました」を出す (3) 起動待ちが15秒間ポーリングし続ける、という3つの不具合につながる。
    -- vim.scheduleでメインループへ戻してからAPI呼び出しを行う(stderrコールバック同様、
    -- ここはfast event contextなのでvim.notify等を直接呼べない)
    vim.schedule(function()
      -- M._guardedにより、既にM.stop()等で別プロセスへ入れ替わっている場合はここに来ない。
      -- つまりこのブロックに到達するのは常に「意図しない終了」であり、
      -- ユーザーが明示的に止めた場合はガードで弾かれてエラー通知は出ない
      M._guarded(proc, function()
        state.proc, state.port, state.root, state.file = nil, nil, nil, nil
        if state.cancel_wait then
          state.cancel_wait()
          state.cancel_wait = nil
        end
        vim.notify(
          ("live-serverが終了しました(exit code=%d): %s"):format(res.code, table.concat(errors)),
          vim.log.levels.ERROR
        )
      end)()
    end)
  end)
  state.proc = proc
  state.port = port
  state.root = root
  state.file = abs

  -- listenする前にブラウザを開くと接続に失敗するため、開くまで待つ。
  -- ここで捕まえたprocの識別情報をM._guardedに渡すことで、待っている間に
  -- 別のstart()/stop()でstate.procが入れ替わっても、古い方が新しい方に干渉しない
  state.cancel_wait = M._wait_until_listening(
    port,
    15000,
    M._guarded(proc, function()
      M.open_url(M.build_url(port, rel))
      vim.notify(("live-serverを起動しました: http://127.0.0.1:%d (ルート: %s)"):format(port, root))
    end),
    M._guarded(proc, function()
      vim.notify("live-serverの起動に失敗しました: " .. table.concat(errors), vim.log.levels.ERROR)
      M.stop()
    end)
  )
end

-- 起動中で、かつ現在のバッファが「今プレビュー中のファイル」と同じ場合だけ停止する。
-- 別ファイルで呼んだ場合はstart()に委ねる(ルートが同じならブラウザを開き直すだけ、
-- 別ルートなら停止してから起動し直す。詳細はM.start参照)。
-- これがないと、a.htmlをプレビュー中にb.htmlを開いて<leader>mpを押した瞬間に
-- セッションが終了してしまい、意図と反してプレビューを壊すだけの操作になる
function M.toggle()
  local path = vim.api.nvim_buf_get_name(0)
  local abs = path ~= "" and vim.fn.fnamemodify(path, ":p") or nil
  if state.proc and state.file == abs then
    M.stop()
    vim.notify("live-serverを停止しました")
  else
    M.start()
  end
end

vim.api.nvim_create_user_command("HtmlPreview", function()
  M.start()
end, { desc = "HTMLをブラウザでライブプレビュー" })

vim.api.nvim_create_user_command("HtmlPreviewStop", function()
  M.stop()
end, { desc = "HTMLのライブプレビューを停止" })

vim.api.nvim_create_user_command("HtmlPreviewToggle", function()
  M.toggle()
end, { desc = "HTMLのライブプレビューを開閉" })

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("html_preview_cleanup", { clear = true }),
  desc = "終了時にlive-serverを停止し、孤児プロセスを残さない",
  callback = function()
    M.stop()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("html_preview_keymap", { clear = true }),
  pattern = "html",
  desc = "htmlバッファに<leader>mpを割り当てる",
  callback = function(ev)
    vim.keymap.set("n", "<leader>mp", M.toggle, {
      buffer = ev.buf,
      desc = "HTMLのライブプレビューを開閉",
    })
  end,
})

return M
