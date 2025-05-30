{ config, pkgs, nixGL, ... }:

let
  pythonWithPip = pkgs.python3.withPackages (ps: with ps; [ pip ]);
in
{
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
    flameshot
    zsh  # Ensure zsh is available

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
    # docker
    # awscli2


    # Shell Enhancement Tools
    fzf
    zoxide
    oh-my-posh  # For your zen.toml prompt theme

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

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Zsh configuration - integrate with existing dotfiles
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # Integration with your existing .zshrc
    initExtra = ''
      # Source your existing dotfiles configuration
      if [ -f "$HOME/dotfiles/.zshrc" ]; then
        source "$HOME/dotfiles/.zshrc"
      fi
    '';
    
    # Basic shell options (your .zshrc will override if needed)
    history = {
      size = 10000;
      path = "$HOME/.zsh_history";
    };
  };

  # Font configuration
  fonts.fontconfig.enable = true;
} 