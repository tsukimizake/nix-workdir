set shell := ["nu", "-c"]

default:
    just fmt
    just run

run:
    sudo darwin-rebuild switch --flake .#(sys host | get hostname | split row '.' | first)

fmt:
    nixfmt flake.nix

search QUERY:
    nix search nixpkgs {{ QUERY }}

edit QUERY:
    nu ./nix-edit.nu {{ QUERY }}

setup:
    sudo nix run nix-darwin  --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .#(sys host | get hostname | split row '.' | first)
