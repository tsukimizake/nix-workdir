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

search QUERY:
    nix search --extra-experimental-features nix-command nixpkgs --extra-experimental-features flakes {{ QUERY }}

edit QUERY:
    nu ./nix-edit.nu {{ QUERY }}

setup:
    let hn = (sys host | get hostname | split row '.' | first); sudo env $"HOST=($hn)" nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --impure --flake $".#($hn)"
