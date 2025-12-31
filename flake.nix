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
                    text = builtins.readFile ./nu_in_nvim;
                  })
                  pkgs.nixfmt
                  pkgs.nodejs
                  pkgs.qmk
                  pkgs.tmux
                  pkgs.ninja
                  pkgs.ripgrep
                  pkgs.fzf
                  pkgs.git
                  pkgs.direnv
                  pkgs.autoconf
                  pkgs.automake
                  pkgs.cmigemo
                  pkgs.gh
                  pkgs.just
                  pkgs.luarocks
                  pkgs.neovim-remote
                  pkgs.nushell
                  pkgs.redo
                  pkgs.rlwrap
                  pkgs.terminal-notifier
                  pkgs.tree-sitter
                  pkgs.wasm-tools
                  pkgs.wasmtime
                  pkgs.mise
                  pkgs.emacs
                ];
                homebrew = {
                  enable = true;
                  user = "t";
                  taps = [
                    "daipeihust/tap"
                  ];
                  brews = [
                    "im-select"
                    "unixodbc"
                    {
                      name = "neovim";
                      args = [ "HEAD" ];
                    }
                    "swi-prolog"
                  ];
                  casks = [
                    "alacritty"
                    "amethyst"
                    "codex"
                    "copilot-cli"
                    "discord"
                    "docker"
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
                    { pkgs, ... }:
                    {
                      home.stateVersion = "23.11";
                      home.packages = [
                        pkgs.hackgen-nf-font
                      ];
                      home.file.".config/alacritty/alacritty.toml" = {
                        source = ./alacritty.toml;
                      };
                      home.file."Library/Application Support/nushell" = {
                        source = ./nushell-config;
                        recursive = true;
                      };
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
