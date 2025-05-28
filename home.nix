{ config, pkgs, nixGL, ... }:

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

    # Clang
    clang
    clang-tools
    valgrind
    gdb

    # Go
    go
    
    # Development Tools
    lazydocker
    lazygit
    

    # Shell Enhancement Tools
    fzf
    zoxide
	
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
}
