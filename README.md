# Update of packages
nix flake update

# New generatrion
home-manager switch --flake .#patrik@work

# Rollback 
home-manager generations
/nix/store/XXXXXXXXXXXXXXX/activate

# Clean up
nix-collect-garbage -d
