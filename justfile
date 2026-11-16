set shell := ["nu", "-c"]

default:
    just fmt
    just run

run:
    # private な trello-cli-2 は root だと認証できないので、先にユーザー権限で store に取得しておく
    nix --extra-experimental-features "nix-command flakes" flake archive
    let hn = (sys host | get hostname | split row '.' | first); sudo env $"HOST=($hn)" darwin-rebuild switch --impure --flake $".#($hn)"

fmt:
    nixfmt flake.nix

git-completions:
    mkdir nushell-config/generated
    let completions = (http get https://raw.githubusercontent.com/fish-shell/fish-shell/4da2a20801914288ded72e2614dd8e0b6e2ccd1a/share/completions/git.fish \
        | generate completions git --source fish \
        | str replace --all --regex '(?m)^#[^\n]*\n|[ \t]+#[^\n]*' ''); \
        $completions | save --force nushell-config/generated/git-completions.nu

search QUERY:
    nix search --extra-experimental-features nix-command nixpkgs --extra-experimental-features flakes {{ QUERY }}

edit QUERY:
    nu ./nix-edit.nu {{ QUERY }}

setup:
    let hn = (sys host | get hostname | split row '.' | first); sudo env $"HOST=($hn)" nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --impure --flake $".#($hn)"
