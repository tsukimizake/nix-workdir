set shell := ["nu", "-c"]

default:
    just fmt
    just run

run:
    sudo darwin-rebuild switch --flake .

fmt:
    nixfmt flake.nix

search QUERY:
    nix search nixpkgs {{ QUERY }}

edit QUERY:
    nu ./nix-edit.nu {{ QUERY }}
