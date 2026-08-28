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
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flix.url = "github:Cj-bc/flix.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      flix,
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
                  pkgs.cmake
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
                  pkgs.goredo
                  pkgs.rlwrap
                  pkgs.terminal-notifier
                  pkgs.tree-sitter
                  pkgs.wasm-tools
                  pkgs.wasmtime
                  pkgs.mise
                  pkgs.emacs
                  pkgs.elan
                  pkgs.ffmpeg
                  pkgs.isabelle
                  pkgs.rocqPackages.rocq-core
                  pkgs.anthy
                  pkgs.croc
                  pkgs.dotnet-sdk_10
                  pkgs.fantomas
                  flix.packages.aarch64-darwin.flix_0_73_0
                ];
                environment.variables = {
                  # nix の dotnet は nix の ICU と macOS の libicucore のシンボル衝突で SIGABRT するため globalization を無効化
                  DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";
                  # dotnet tool の apphost が runtime を探すのに必要 (PATH は見ない)
                  DOTNET_ROOT = "${pkgs.dotnet-sdk_10}/share/dotnet";
                };
                # バイナリは ~/.local/spacemouse-arbiter で `just build` する
                # (nix でビルドすると再ビルドのたびに Accessibility 許可の手動再登録が必要になるため)
                launchd.user.agents.spacemouse-arbiter = {
                  serviceConfig = {
                    Label = "local.spacemouse-arbiter";
                    ProgramArguments = [ "/Users/tsukimizake/.local/bin/spacemouse-arbiter" ];
                    RunAtLoad = true;
                    KeepAlive = true;
                    StandardOutPath = "/Users/tsukimizake/Library/Logs/spacemouse-arbiter.log";
                    StandardErrorPath = "/Users/tsukimizake/Library/Logs/spacemouse-arbiter.log";
                  };
                };
                homebrew = {
                  enable = true;
                  user = "tsukimizake";
                  taps = [
                    {
                      name = "daipeihust/tap";
                      trusted = true;
                    }
                  ];
                  brews = [
                    "nushell"
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
                    "claude-code@latest"
                    "copilot-cli"
                    "forklift"
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
                    {
                      pkgs,
                      config,
                      lib,
                      ...
                    }:
                    let
                      workdir = "/Users/tsukimizake/workdir";
                    in
                    {
                      home.stateVersion = "23.11";
                      # force = true はファイル/symlinkしか上書きできないため、
                      # nushellが生成した実ディレクトリはリンク作成前に消す
                      home.activation.removeNushellConfigDir = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
                        nushellDir="$HOME/Library/Application Support/nushell"
                        if [ -e "$nushellDir" ] && [ ! -L "$nushellDir" ]; then
                          run rm -rf "$nushellDir"
                        fi
                      '';
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
                      home.file.".config/spacemouse-arbiter/apps.txt" = {
                        source = config.lib.file.mkOutOfStoreSymlink "/Users/tsukimizake/.local/spacemouse-arbiter/apps.txt";
                        force = true;
                      };
                      home.file.".config/spacemouse-arbiter/settings.txt" = {
                        source = config.lib.file.mkOutOfStoreSymlink "/Users/tsukimizake/.local/spacemouse-arbiter/settings.txt";
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
        {
          ${hostname} = mkDarwinSystem hostname;
        };
    };
}
