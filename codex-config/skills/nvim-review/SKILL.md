---
name: nvim-review
description: Neovim (diffview) 上で人間が付けたレビューコメントを `/tmp/nvim-review/<project>/<branch>/comments.json` から回収し、全件クローズして `status` / `response` を書き戻すフロー。「diffviewでコメント付けた」「レビューコメント読んで」「.nvim-review 読んで」「コメント反映して」と言われたとき、および対象プロジェクトの `/tmp/nvim-review/<project>/` にコメントがあるときに使う。
---

# nvim-review: ファイル経由のレビューコメント回収

人間は Neovim の diffview や fugitive で差分を読み、`:ReviewComment`（`<leader>rc`）でコメントを書く。
コメントは `/tmp/nvim-review/<project>/<branch>/comments.json` に追記される。
`<branch>` はコメントを付けたときに checkout していたブランチ名で、`feature/foo` のようなスラッシュはそのままディレクトリになる。detached HEAD なら短縮 SHA（11 桁）。
`<project>` は git ルートの実パス（シンボリックリンクを解決した絶対パス）を改行なしで SHA-256 にした値。プロジェクトと worktree ごとに保存先が分かれる。`/tmp` の掃除や再起動でコメントが消えることがある。
AI は 現在のブランチ のファイルを読んで対応する。パスは以下で求める。

```nu
let repo = (git rev-parse --show-toplevel | str trim | path expand --strict)
let project = ($repo | hash sha256)
let branch = (git symbolic-ref --quiet --short HEAD | complete)
let branch = if $branch.exit_code == 0 {
  $branch.stdout | str trim
} else if $branch.exit_code == 1 {
  git rev-parse --short=11 HEAD | str trim | str substring 0..<11
} else {
  error make {msg: $branch.stderr}
}
let review_dir = ("/tmp/nvim-review" | path join $project)
let f = ($review_dir | path join $branch "comments.json")
```

別ブランチのコメントを読む必要があるときは `glob ($review_dir | path join "**/comments.json")` で一覧して、どれを読むかユーザに確認する。

## コメントファイルの形式

```json
{
  "version": 1,
  "comments": [
    {
      "id": "20260914-211501-1",
      "filePath": "lib/foo/bar.ex",
      "line": 42,
      "endLine": 45,
      "rev": "LOCAL",
      "summary": "ここは Manager に寄せたい",
      "rationale": "resolver に検証がないように見える",
      "author": "user",
      "createdAt": "2026-09-14T12:15:01Z",
      "status": "open"
    }
  ]
}
```

- アンカーは `rev` + `filePath` + `line`。`endLine` があれば範囲選択。
- `rev` はそのバッファが表示していたリビジョン。
  - `LOCAL`: 作業ツリー。`filePath` をそのまま開けばよい。
  - 短縮 SHA（11 桁）: そのコミット時点の内容。行番号はそのリビジョンでのものなので、`git show <rev>:<filePath>` で本文を読む。
- `filePath` は git ルートからの相対パスで、`rev` 時点でのパス（リネーム前後で異なりうる）。
- `summary` が 1 行目、`rationale` が残り。本文はこの 2 つを原文のまま扱う。要約しない。
- `status` は `open` / `fixed` / `question` / `answered`。AI が更新する。
- `response` は AI が対応内容を書き戻すフィールド（任意）。

## 手順

### 1. 回収する

このスキルが起動したら、前置きや確認をせず最初のアクションとしてファイルを読む。
comments.jsonは長くなりうるのでskill自体のデバッグ以外では基本的にファイル全体を `cat` すべきではない。nushell で `open` して `status == open` だけを取る。

```nu
let repo = (git rev-parse --show-toplevel | str trim | path expand --strict)
let project = ($repo | hash sha256)
let branch = (git symbolic-ref --quiet --short HEAD | complete)
let branch = if $branch.exit_code == 0 {
  $branch.stdout | str trim
} else if $branch.exit_code == 1 {
  git rev-parse --short=11 HEAD | str trim | str substring 0..<11
} else {
  error make {msg: $branch.stderr}
}
let review_dir = ("/tmp/nvim-review" | path join $project)
let f = ($review_dir | path join $branch "comments.json")
open $f | get comments | where status == open | select id filePath line endLine? rev summary rationale? | table -e
```

読めないときだけ `cat` で中身を見る。
ファイルが無い・`empty list` なら勝手に進めず、`glob ($review_dir | path join "**/comments.json")` で他ブランチのファイルが無いかを見て、ブランチが合っているかをユーザに確認する。
コメントがアンカーしている行を実際に開き、周辺コードを読んでから判断する。`rev` が `LOCAL` 以外のものは `git show <rev>:<filePath>` で読む。

### 2. 全件クローズする

記録は `comments.json` に行う。`open` なコメントを1件も残さない。出口は以下の3種。

1. 修正 — 指摘が明確で妥当なとき。指摘の言葉どおりの範囲だけ直す。ついでのリファクタは混ぜず、`response` に「別途提案」として書く。
2. 逆質問 — 意図が読み取れない、複数の解釈で結果が変わるとき。解釈の候補とそれぞれの帰結を示して聞く。他の項目は先に片付ける。
3. 返答 — 修正しない方がよいと考えるとき。黙って無視しない。理由を述べ、それでも直してほしければ対応すると選択権を返す。

修正が済んだら、そのラウンドの変更をまとめてプロジェクトの lint / format / test にかける。コマンドはそのリポジトリの CLAUDE.md / AGENTS.md に従う。

### 3. ファイルに書き戻す

各コメントの `status` と `response` を更新する。他のフィールドは変更・削除しない（Neovim 側の表示と id 参照が壊れる）。

- 修正した → `"status": "fixed"`, `"response": "何をどう直したか"`
- 逆質問した → `"status": "question"`, `"response": "質問文"`
- 修正しない → `"status": "answered"`, `"response": "理由"`

書き戻すと Neovim の `:ReviewNotes` が元の指摘の隣に対応結果を表示する。

### 4. 報告する

今回触ったコメントごとに、summary / rationale の原文引用と `response` に書いた内容を提示し、件数の内訳を添える。
内訳は `comments.json` から取る。

```nu
open $f | get comments | get status | uniq --count
```

`question` が残っているなら未クローズであることを明言する。 「全部対応しました」と言えるのは `open` と `question` が 0 件のときだけ。

## 他者の PR をレビューしている場合

自分（AI）が実装者ではなく、人間が他者の PR を読んでいる場合は read-only。
コードを直さず、`git checkout` もしない。各コメントについて指摘が成立するかを事実で示し、
PR に貼れる文面を `response` に書く。PR への投稿（`gh pr review` 等）はしない。貼るかどうかはレビュアーが決める。

## 落とし穴

- 要約による意図の消失 — 報告と `response` では原文を引用する。
- `rev` の見落とし — `rev` がコミット SHA のコメントを作業ツリーの行番号で読むとズレる。
- リネームされたファイル — 旧リビジョンで付けたコメントの `filePath` はリネーム前のパス。作業ツリーに同名ファイルが無ければ `git log --follow` か diff の rename 情報で新パスを引き当て、`git show <rev>:<filePath>` で本文を読む。Neovim 側では作業ツリーのバッファに表示されないので、ユーザが「見えない」と言ったらこのケースを疑う。
- ファイルの上書き — `comments.json` を書き戻すときは `status` / `response` 以外を触らない。整形し直す場合も 1 コメント 1 行の形を保つ。
- 完了後の掃除 — 全項目クローズ後にコメントを消したい場合は、ユーザに確認してから `comments.json` の該当エントリを削除する（履歴を PR 本文に使いたいことがある）。
