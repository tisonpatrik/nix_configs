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

    # ====================== System Manager ===================== #
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ghostty, nixGL, zen-browser, system-manager, ... }:
  let
    system = "x86_64-linux";
    pkgsFor = system: import nixpkgs {
      inherit system;
      config = {
        # Explicitly allow unfree packages that are used in this configuration
        allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [ 
          "cursor"           # Cursor editor (unfree)
          "signal-desktop"   # Signal messaging app (unfree)
          "ghostty"          # Ghostty terminal (unfree)
          "zen-browser"      # Zen browser (unfree)
          "steam"            # Steam gaming platform (unfree)
          "steam-original"   # Steam original package (unfree)
          "steam-unwrapped"  # Steam unwrapped package (unfree)
          "steam-run"        # Steam FHS environment (unfree)
        ];
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
    
    # System-level configurations for managing shell and system packages
    systemConfigs = {
      default = system-manager.lib.makeSystemConfig {
        modules = [
          ./system.nix
        ];
      };
    };
  };
}
