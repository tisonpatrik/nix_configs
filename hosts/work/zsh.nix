{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    zsh  
    fzf 
    zoxide
    oh-my-posh
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      # Source your existing dotfiles configuration
      if [ -f "$HOME/nixos-config/dotfiles/zsh/.zshrc" ]; then
        source "$HOME/nixos-config/dotfiles/zsh/.zshrc"
      fi
    '';

    history = {
      size = 10000;
      path = "$HOME/.zsh_history";
    };
  };
}
