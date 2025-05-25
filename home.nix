{ config, pkgs, ... }:

{
  home.username = "patrik";
  home.homeDirectory = "/home/patrik";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    git
    neovim
	tree
	clang
	clang-tools
	valgrind
	gdb
	ghostty
  ];

  programs.git = {
    enable = true;
    userName = "tisonpatrik";
    userEmail = "patriktison@gmail.com";
  };
}
