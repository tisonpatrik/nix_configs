{
  description = "Patrik's Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
    nixGL = {
      url = "github:guibou/nixGL";
    };
  };

  outputs = { self, nixpkgs, home-manager, ghostty, nixGL, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { 
        inherit system;
        overlays = [
          ghostty.overlays.default
        ];
      };
    in {
      homeConfigurations = {
        "patrik" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit nixGL; };
          modules = [ ./home.nix ];
        };
      };
    };
}
