{ config, pkgs, nixGL, c-formatter-42, ... }:

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
    norminette
    c-formatter-42.packages.${pkgs.system}.default

    # Go
    go
    buf
    gopls
    sqlc

	  # Python
    pythonWithPip
    uv

    # JS
    nodejs_24
	  yarn

    # development Tools
    docker
    docker-compose
    lazydocker
    lazygit
 
    # Work-specific tools
    k9s
    awscli2

    # Networking
    wireguard-tools

    # Text Editors
    zed-editor
    neovim
    # Cursor Editor (with nixGL wrapper)
    code-cursor
    (pkgs.writeShellScriptBin "cursor-nixgl" ''
      export SHELL=${pkgs.zsh}/bin/zsh
      export NIXOS_OZONE_WL="1"
      exec ${nixGL.packages.${pkgs.system}.nixGLIntel}/bin/nixGLIntel ${pkgs.code-cursor}/bin/cursor "$@"
    '')

    # Terminal
    (pkgs.writeShellScriptBin "ghostty" ''
      exec ${nixGL.packages.${pkgs.system}.nixGLIntel}/bin/nixGLIntel ${pkgs.ghostty}/bin/ghostty "$@"
    '')
  ];

  programs.git = {
    enable = true;
    userName = "tisonpatrik";
    userEmail = "patriktison@gmail.com";  # Consider using work email here
    extraConfig = {
      core.editor = "vim";
    };
  };
}
