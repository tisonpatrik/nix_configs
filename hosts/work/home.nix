{ config, pkgs, nixGL, ... }:

let
  pythonWithPip = pkgs.python3.withPackages (ps: with ps; [ pip ]);
  lib = pkgs.lib;
in
{

  home.username = "patrik";
  home.homeDirectory = "/home/patrik";
  home.stateVersion = "24.05";
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;

  home.packages = with pkgs; [

     # Clang
    clang
    clang-tools
    valgrind
    gdb

    # Go
    go
    buf
    air
    gopls

	  # Python
    pythonWithPip
    uv

    # JS
    nodejs_24
	  yarn

    # Container & Development Tools
    docker
    docker-compose
    lazydocker
    lazygit

    # Work-specific tools
    k9s
    awscli2

    # Networking
    wireguard-tools

    # Work Apps (minimal personal apps)
    # signal-desktop  # Commented out for work setup

    # Cursor Editor (with nixGL wrapper)
    code-cursor
    (pkgs.writeShellScriptBin "cursor-nixgl" ''
      export SHELL=${pkgs.zsh}/bin/zsh
      export NIXOS_OZONE_WL="1"
      exec ${nixGL.packages.${pkgs.system}.nixGLIntel}/bin/nixGLIntel ${pkgs.code-cursor}/bin/cursor "$@"
    '')

    # Other Applications with nixGL wrapper
    (pkgs.writeShellScriptBin "ghostty" ''
      exec ${nixGL.packages.${pkgs.system}.nixGLIntel}/bin/nixGLIntel ${pkgs.ghostty}/bin/ghostty "$@"
    '')
  ];

  programs.git = {
    enable = true;
    userName = "tisonpatrik";
    userEmail = "patriktison@gmail.com";  # Consider using work email here
    extraConfig = {
      core.editor = "nvim";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Automatic Stow activation
  home.activation = {
    stowDotfiles = config.lib.dag.entryAfter ["writeBoundary"] ''
      echo "🔗 Setting up dotfiles with Stow..."

      # Check if the stow-dotfiles directory exists
      if [ -d "${config.home.homeDirectory}/repos/personal/nix-config/stow-dotfiles" ]; then
        cd ${config.home.homeDirectory}/repos/personal/nix-config/stow-dotfiles
        ${pkgs.stow}/bin/stow -t ${config.home.homeDirectory} zsh ohmyposh fastfetch 2>/dev/null || true
        echo "✅ Dotfiles stowed successfully"
      else
        echo "⚠️  Stow dotfiles directory not found, skipping setup"
      fi
    '';
  };
}
