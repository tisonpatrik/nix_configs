{ config, pkgs, nixGL, zen_browser, ... }:
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
    stow

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

    # Shell Enhancement Tools
    zsh
    fzf
    zoxide
    oh-my-posh

    # Apps 
    signal-desktop

    # Applications with nixGL wrapper
    (pkgs.writeShellScriptBin "ghostty" ''
      exec ${nixGL.packages.${pkgs.system}.nixGLIntel}/bin/nixGLIntel ${pkgs.ghostty}/bin/ghostty "$@"
    '')
  ];

  programs.git = {
    enable = true;
    userName = "tisonpatrik";
    userEmail = "patriktison@gmail.com";
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

  # All shell integrations (zsh, fzf, zoxide) are managed by Stow
  # The activation script will create ~/.zshrc symlink via Stow

  # Automatic Stow activation
  home.activation = {
    stowDotfiles = config.lib.dag.entryAfter ["writeBoundary"] ''
      echo "🔗 Setting up dotfiles with Stow..."
      
      # Check if the stow-dotfiles directory exists
      if [ -d "${config.home.homeDirectory}/repos/nix_configs/stow-dotfiles" ]; then
        cd ${config.home.homeDirectory}/repos/nix_configs/stow-dotfiles
        ${pkgs.stow}/bin/stow -t ${config.home.homeDirectory} zsh ohmyposh 2>/dev/null || true
        echo "✅ Dotfiles stowed successfully"
      else
        echo "⚠️  Stow dotfiles directory not found, skipping setup"
      fi
    '';
  };
}
