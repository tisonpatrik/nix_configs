{ lib, pkgs, ... }:
{
  config = {
    nixpkgs.hostPlatform = "x86_64-linux";
    
    # Allow system-manager to run on non-NixOS systems (Pop!_OS/Ubuntu)
    system-manager.allowAnyDistro = true;

    environment = {
      # Install system-wide packages
      systemPackages = with pkgs; [
        zsh
        fzf
        zoxide
        oh-my-posh
        stow
        # Docker and container tools
        docker
        docker-compose
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

        # Docker daemon configuration
        "docker/daemon.json".text = ''
          {
            "log-driver": "journald",
            "storage-driver": "overlay2",
            "default-address-pools": [
              {
                "base": "172.30.0.0/16",
                "size": 24
              }
            ]
          }
        '';
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

    # Docker setup service
    systemd.services.docker-setup = {
      description = "Setup Docker daemon and user permissions";
      enable = true;
      wantedBy = [ "system-manager.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # Create docker group if it doesn't exist
        if ! getent group docker > /dev/null 2>&1; then
          echo "Creating docker group..."
          ${pkgs.shadow}/bin/groupadd docker
        fi

        # Add user to docker group if not already a member
        if ! groups patrik | grep -q docker; then
          echo "Adding user patrik to docker group..."
          ${pkgs.shadow}/bin/usermod -aG docker patrik
          echo "User added to docker group. You may need to log out and back in."
        else
          echo "User patrik is already in docker group"
        fi

        # Ensure docker directory exists
        mkdir -p /etc/docker

        # Start docker daemon if not running (Pop!_OS specific)
        if ! systemctl is-active --quiet docker 2>/dev/null; then
          echo "Docker daemon not running via system systemd, trying to start..."
          # On Pop!_OS, we might need to enable the system docker service
          if systemctl list-unit-files | grep -q docker.service; then
            systemctl enable docker.service || true
            systemctl start docker.service || true
          fi
        fi
      '';
    };
  };
} 