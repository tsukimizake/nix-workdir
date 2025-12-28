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
   source ./fzflist.nu; let choice = (nix search --json nixpkgs {{ QUERY }} | from json | transpose | each { {name: $in.column0, desc: $in.column1.description, pname: $in.column1.pname, version: $in.column1.version} } | fzflist name); nix edit $"nixpkgs#($choice.pname)"

