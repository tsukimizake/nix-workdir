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

    outputs = {
        self,
        nixpkgs,
        home-manager,
        nix-darwin,
    }: {
        darwinConfigurations = {
            "tsukimizakenoMacBook-Pro" = nix-darwin.lib.darwinSystem {
                # x86 macOS 使ってる場合は、"x86_64-darwin" を指定する
                system = "aarch64-darwin";

                modules = [
                    ({ config, pkgs, ... }: {
                        system = {
                            stateVersion = 5;
                            primaryUser = "t";
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
def main [--cmd : string ] {
  if $cmd != null {
    nu -c $cmd
  } else {
    nu -e "$env.RUN_IN_NVIM = true"
  }
}
			    '';
			  })
			];
                        homebrew = {
                            enable = true;
			    user = "t";
                            brews = [
				"autoconf"
				"automake"
				"awscli"
				"cmigemo"
				"coreutils"
				"direnv"
				"emscripten"
				"ffmpeg"
				"fzf"
				"gh"
				"ghcup"
				"git"
				"gnuplot"
				"go"
				"guile"
				"harfbuzz"
				# "im-select"
				"imagemagick"
				"jq"
				"just"
				"libtool"
				"libyaml"
				"luarocks"
				"mise"
				{ name = "neovim"; args = [ "HEAD" ]; }
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
				# "qmk"
				"readline"
				"redo"
				"ripgrep"
				"rlwrap"
				"sevenzip"
				"shellcheck"
				"sox"
				"swi-prolog"
				"terminal-notifier"
				"tesseract"
				"tmux"
				"tree"
				"tree-sitter"
				"unixodbc"
				"unzip"
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
				"font-hackgen-nerd"
				"openscad@snapshot"
				"slack"
				"steam"
				"vnc-viewer"
                            ];
                        };
                    })
                    home-manager.darwinModules.home-manager
                ];
            };
        };
    };
}
