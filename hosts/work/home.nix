{ config, pkgs, nixGL, ... }:

let
  pythonWithPip = pkgs.python3.withPackages (ps: with ps; [ pip ]);
  lib = pkgs.lib;
in
{
  imports = [
    ./zsh.nix
  ];

  home.username = "patrik";
  home.homeDirectory = "/home/patrik";
  home.stateVersion = "24.05";
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Version Control
    git

    # System Utilities
    tree
    direnv
    btop

    # Fonts
    fontconfig
    dejavu_fonts
    liberation_ttf

    # Clang
    clang
    clang-tools
    valgrind
    gdb

    # Go
    go

    # Python
    pythonWithPip
    uv

    # Development Tools
    lazydocker
    lazygit
    
    # Work-specific tools
    k9s
    # awscli2
    # docker
    

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

  # Font configuration
  fonts.fontconfig.enable = true;
}