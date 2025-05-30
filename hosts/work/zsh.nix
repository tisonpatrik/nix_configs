{ config, pkgs, ... }:

{
  # Zsh-related packages
  home.packages = with pkgs; [
    zsh  # Ensure zsh is available
    fzf  # Fuzzy finder
    zoxide  # Smart cd replacement
    oh-my-posh  # For your zen.toml prompt theme
  ];

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
} 