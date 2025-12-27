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
                  pkgs.autoconf
                  pkgs.automake
                  pkgs.cmigemo
                  pkgs.coreutils
                  pkgs.emscripten
                  pkgs.ffmpeg
                  pkgs.gh
                  pkgs.gnuplot
                  pkgs.go
                  pkgs.guile
                  pkgs.harfbuzz
                  pkgs.imagemagick
                  pkgs.just
                  pkgs.libtool
                  pkgs.libyaml
                  pkgs.luarocks
                  pkgs.neovim-remote
                  pkgs.nim
                  pkgs.ninja
                  pkgs.nushell
                  pkgs.opam
                  pkgs.pkgconf
                  pkgs.poppler
                  pkgs.protobuf
                  pkgs.readline
                  pkgs.redo
                  pkgs.rlwrap
                  pkgs.shellcheck
                  pkgs.sox
                  pkgs.tesseract
                  pkgs.terminal-notifier
                  pkgs.tree-sitter
                  pkgs.uv
                  pkgs.vhs
                  pkgs.wasm-tools
                  pkgs.wasmtime
                  pkgs.wxwidgets_3_3
                ];
                homebrew = {
                  enable = true;
                  user = "t";
                  taps = [
                    "daipeihust/tap"
                  ];
                  brews = [
                    "awscli"
                    "ghcup"
                    "im-select"
                    "mise"
                    "unixodbc"
                    {
                      name = "neovim";
                      args = [ "HEAD" ];
                    }
                    "openssl@3"
                    "python-matplotlib"
                    "sevenzip"
                    "swi-prolog"
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
