{
  description = "Patrik's Nix Flake";

  inputs = {
    # ========================= Core inputs ========================= #
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # ====================== Home Manager ======================= #
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ======================= Applications ======================= #
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    # ======================== Graphics ========================= #
    nixGL = {
      url = "github:guibou/nixGL";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ghostty, nixGL, zen-browser,... }:
  let
    system = "x86_64-linux";
    pkgsFor = system: import nixpkgs {
      inherit system;
      config = {
        allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "cursor" ];
      };
      overlays = [ ghostty.overlays.default ];
    };
    mkHome = sys: mods: home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor sys;
      extraSpecialArgs = { inherit nixGL zen-browser; };
      modules = mods;
    };
  in {
    homeConfigurations = {
      "patrik@work" = mkHome system [ ./hosts/work/home.nix ];
      "patrik@home" = mkHome system [ ./hosts/home/home.nix ];
      "patrik" = mkHome system [ ./home.nix ];
    };
    
  };
}
