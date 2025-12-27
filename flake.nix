{
  description = "A flake to provision my environment";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
    }:
    {
      darwinConfigurations = {
        "tsukimizakenoMacBook-Pro" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";

          modules = [
            (
              { config, pkgs, ... }:
              {
                system = {
                  stateVersion = 5;
                  primaryUser = "t";
                };
                users.users.t = {
                  name = "t";
                  home = "/Users/t";
                };

                environment.systemPath = [
                  "/opt/homebrew/bin"
                  "/opt/homebrew/sbin"
                ];
                environment.systemPackages = [
                  (pkgs.writeTextFile {
                    name = "nu_in_nvim";
                    destination = "/bin/nu_in_nvim";
                    executable = true;
                    text = ''
                      #!/usr/bin/env nu
                      def main [--cmd (-c) : string ] {
                        if $cmd != null {
                          nu -c $cmd
                        } else {
                          nu -e "$env.RUN_IN_NVIM = true"
                        }
                      }
                      			    '';
                  })
                  pkgs.nixfmt
                  pkgs.nodejs
                  pkgs.qmk
                  pkgs.tmux
                  pkgs.ripgrep
                  pkgs.fzf
                  pkgs.git
                  pkgs.direnv
                  pkgs.jq
                  pkgs.tree
                  pkgs.unzip
                ];
                homebrew = {
                  enable = true;
                  user = "t";
                  taps = [
                    "daipeihust/tap"
                  ];
                  brews = [
                    "autoconf"
                    "automake"
                    "awscli"
                    "cmigemo"
                    "coreutils"
                    "direnv"
                    "emscripten"
                    "ffmpeg"
                    "gh"
                    "ghcup"
                    "gnuplot"
                    "go"
                    "guile"
                    "harfbuzz"
                    "im-select"
                    "imagemagick"
                    "just"
                    "libtool"
                    "libyaml"
                    "luarocks"
                    "mise"
                    {
                      name = "neovim";
                      args = [ "HEAD" ];
                    }
                    "neovim-remote"
                    "nim"
                    "ninja"
                    "nushell"
                    "opam"
                    "openssl@3"
                    "pkgconf"
                    "poppler"
                    "protobuf"
                    "python-matplotlib"
                    "readline"
                    "redo"
                    "rlwrap"
                    "sevenzip"
                    "shellcheck"
                    "sox"
                    "swi-prolog"
                    "terminal-notifier"
                    "tesseract"
                    "tree-sitter"
                    "unixodbc"
                    "uv"
                    "vhs"
                    "wasm-tools"
                    "wasmtime"
                    "wxwidgets"
                  ];
                  casks = [
                    "alacritty"
                    "amethyst"
                    "codex"
                    "copilot-cli"
                    "discord"
                    "docker"
                    "font-hackgen-nerd"
                    "openscad@snapshot"
                    "slack"
                    "steam"
                    "vnc-viewer"
                  ];
                };
              }
            )
            home-manager.darwinModules.home-manager
            (
              { ... }:
              {
                home-manager = {
                  users.t =
                    { ... }:
                    {
                      home.stateVersion = "23.11";
                      programs.tmux = {
                        enable = true;
                        extraConfig = builtins.readFile ./tmux.conf;
                      };
                    };
                };
              }
            )
          ];
        };
      };
    };
}
