default:
  just fmt
  just run
run:
  sudo darwin-rebuild switch --flake .
fmt:
  nixfmt flake.nix
