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

    # Shell Enhancement Tools (needed for your .zshrc)
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

  # Commented out - zoxide is configured in .zshrc with custom options
  # programs.zoxide = {
  #   enable = true;
  #   enableZshIntegration = true;
  #   options = [ "--cmd cd" ];
  # };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Commented out - fzf is configured in .zshrc with custom key bindings
  # programs.fzf = {
  #   enable = true;
  #   enableZshIntegration = true;
  # };

  # Zsh configuration - integrate with existing dotfiles
  programs.zsh = {
    enable = true;
    # Disable these since they're handled by zinit in your .zshrc
    enableCompletion = false;  # Handled by zinit with zsh-completions
    autosuggestion.enable = false;  # Handled by zinit with zsh-autosuggestions  
    syntaxHighlighting.enable = false;  # Handled by zinit with zsh-syntax-highlighting
    
    # Integration with your existing .zshrc
    initContent = ''
      # Source your existing dotfiles configuration
      if [ -f "$HOME/nixos-config/dotfiles/zsh/.zshrc" ]; then
        source "$HOME/nixos-config/dotfiles/zsh/.zshrc"
      fi
    '';
    
    # Let your .zshrc handle history configuration via HISTSIZE, HISTFILE, etc.
    # Only set basic fallbacks here
    history = {
      size = 10000;
      path = "$HOME/.zsh_history";
    };
  };

  # Font configuration
  fonts.fontconfig.enable = true;
} 