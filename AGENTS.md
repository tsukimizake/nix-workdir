# AGENTS.md

このリポジトリ (`/Users/tsukimizake/workdir`) は Nix flake (`flake.nix`) によって環境構築を管理している。

## パッケージ追加の指令が来たら

`<パッケージ名>入れて`、`<パッケージ名> をインストールして`、`add <package>` のような指令を受け取った場合は、**Homebrew や `brew install` で対処せず、`flake.nix` を編集して nixpkgs 由由で追加する**。

### 編集手順

1. `flake.nix` を読む
2. `environment.systemPackages` のリスト末尾付近 (`flix.packages...` の直前) に `pkgs.<パッケージ名>` を追加する
3. 追加後、`darwin-rebuild switch --flake .` 相当の操作を行う前提で記述する (ユーザーが実行する)
4. nixpkgs に存在しないパッケージの場合のみ Homebrew (`homebrew.brews` / `homebrew.casks`) の追加を検討する

### 例

`croc入れて` → `flake.nix` の `environment.systemPackages` に `pkgs.croc` を追加する。

## その他

- このリポジトリのコミットは明示的に指示された場合のみ行う
- フォーマッタは `nixfmt` (既に systemPackages に入っている) を使用する
