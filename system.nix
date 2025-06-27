{ lib, pkgs, ... }:
{
  config = {
    nixpkgs.hostPlatform = "x86_64-linux";
    
    # Allow system-manager to run on non-NixOS systems (Pop!_OS/Ubuntu)
    system-manager.allowAnyDistro = true;

    environment = {
      # Install zsh system-wide
      systemPackages = with pkgs; [
        zsh
        fzf
        zoxide
        oh-my-posh
        stow
      ];

      # Add zsh to /etc/shells so it's recognized as a valid shell
      etc = {
        "shells".text = ''
          # System shells
          /bin/sh
          /bin/bash
          /usr/bin/bash
          /bin/dash
          /usr/bin/dash
          
          # Nix-managed shells
          ${pkgs.zsh}/bin/zsh
          /home/patrik/.nix-profile/bin/zsh
        '';
        
        # Create a script to change user shell
        "change-shell.sh" = {
          text = ''
            #!/bin/bash
            # Script to change user shell to zsh
            if [ "$(id -u)" != "0" ]; then
              echo "This script should be run as root"
              exit 1
            fi
            
            ZSH_PATH="${pkgs.zsh}/bin/zsh"
            if [ -f "$ZSH_PATH" ]; then
              echo "Changing shell for user patrik to $ZSH_PATH"
              chsh -s "$ZSH_PATH" patrik
              echo "Shell changed successfully"
            else
              echo "Zsh not found at $ZSH_PATH"
              exit 1
            fi
          '';
          mode = "0755";
        };
      };
    };

    # Create a systemd service to change the user's shell on activation
    systemd.services.set-user-shell = {
      description = "Set user shell to zsh";
      enable = true;
      wantedBy = [ "system-manager.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # Check if user's shell is already zsh
        CURRENT_SHELL=$(getent passwd patrik | cut -d: -f7)
        ZSH_PATH="${pkgs.zsh}/bin/zsh"
        
        if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
          echo "Changing shell for user patrik from $CURRENT_SHELL to $ZSH_PATH"
          ${pkgs.util-linux}/bin/chsh -s "$ZSH_PATH" patrik
          echo "Shell changed successfully"
        else
          echo "User shell is already set to zsh"
        fi
      '';
    };
  };
} 