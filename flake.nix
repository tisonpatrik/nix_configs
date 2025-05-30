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
  };

  outputs = { self, nixpkgs, home-manager, ghostty, nixGL, ... }:
    let
      # =================== Helper Functions =================== #
      system = "x86_64-linux";
      
      pkgsFor = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "cursor"
          ];
        };
        overlays = [
          ghostty.overlays.default
        ];
      };

      mkHome = system: modules: home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor system;
        extraSpecialArgs = { inherit nixGL; };
        modules = modules;
      };

    in {
      # ================ Home Manager Configurations ================ #
      homeConfigurations = {
        "patrik@home" = mkHome system [ ./hosts/home/home.nix ];
        "patrik@work" = mkHome system [ ./hosts/work/home.nix ];
        
        # ====================== Legacy config ====================== #
        # Keep the original for backward compatibility
        "patrik" = mkHome system [ ./home.nix ];
      };

    };
}
