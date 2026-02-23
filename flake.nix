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
    let
      mkDarwinSystem =
        hostname:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";

          modules = [
            (
              { config, pkgs, ... }:
              {
                system = {
                  stateVersion = 5;
                  primaryUser = "tsukimizake";
                };
                users.users.tsukimizake = {
                  name = "tsukimizake";
                  home = "/Users/tsukimizake";
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
                  (pkgs.writeShellScriptBin "claude-code-acp" ''
                    exec ${pkgs.nodejs}/bin/npx @zed-industries/claude-code-acp "$@"
                  '')
                  (pkgs.writeShellScriptBin "trello" ''
                    exec ${pkgs.nodejs}/bin/npx @anthropic/trello-mcp-server "$@"
                  '')
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
                  pkgs.lean4
                ];
                homebrew = {
                  enable = true;
                  user = "tsukimizake";
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
                    "ghostty"
                    "amethyst"
                    "discord"
                    "figma"
                    "docker-desktop"
                    "neovide-app"
                    "openscad@snapshot"
                    "prusaslicer"
                    "slack"
                    "steam"
                    "vnc-viewer"
                    "azookey"
                    "claude-code"
                    "copilot-cli"
                    "forklift"
                    "ghostty"
                  ];
                };
              }
            )
            home-manager.darwinModules.home-manager
            (
              { config, ... }:
              {
                home-manager = {
                  users.tsukimizake =
                    { pkgs, config, ... }:
                    let
                      workdir = "/Users/tsukimizake/workdir";
                    in
                    {
                      home.stateVersion = "23.11";
                      home.packages = [
                        pkgs.hackgen-nf-font
                      ];
                      home.file.".config/alacritty/alacritty.toml" = {
                        source = config.lib.file.mkOutOfStoreSymlink "${workdir}/alacritty.toml";
                        force = true;
                      };
                      home.file."Library/Application Support/nushell" = {
                        source = config.lib.file.mkOutOfStoreSymlink "${workdir}/nushell-config";
                        force = true;
                      };
                      home.file."Library/Application Support/com.mitchellh.ghostty/config" = {
                        source = config.lib.file.mkOutOfStoreSymlink "${workdir}/ghostty-config";
                        force = true;
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
    in
    {
      darwinConfigurations =
        let
          hostname = builtins.getEnv "HOST";
        in
        { ${hostname} = mkDarwinSystem hostname; };
    };
}
