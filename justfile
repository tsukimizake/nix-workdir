set shell := ["nu", "-c"]

default:
    just fmt
    just run

run:
    let hn = (sys host | get hostname | split row '.' | first); sudo env $"HOST=($hn)" darwin-rebuild switch --impure --flake $".#($hn)"

fmt:
    nixfmt flake.nix

search QUERY:
    nix search nixpkgs {{ QUERY }}

edit QUERY:
    nu ./nix-edit.nu {{ QUERY }}

setup:
    sudo nix run nix-darwin  --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --impure --flake .#(sys host | get hostname | split row '.' | first)
