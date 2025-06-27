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

    # Docker daemon service (nix-managed)
    systemd.services.docker = {
      enable = true;
      description = "Docker Application Container Engine";
      documentation = [ "https://docs.docker.com" ];
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "notify";
        Environment = [
          "PATH=${lib.makeBinPath [
            pkgs.docker
            pkgs.coreutils
            pkgs.kmod
          ]}:/usr/bin:/sbin"
        ];
        ExecStart = "${pkgs.docker}/bin/dockerd";
        ExecStartPost = [
          "${pkgs.coreutils}/bin/chmod 666 /var/run/docker.sock"
          "${pkgs.coreutils}/bin/chown root:docker /var/run/docker.sock"
        ];
        ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
        TimeoutStartSec = 0;
        RestartSec = 2;
        Restart = "always";
        StartLimitBurst = 3;
        StartLimitInterval = "60s";
        LimitNOFILE = "infinity";
        LimitNPROC = "infinity";
        LimitCORE = "infinity";
        TasksMax = "infinity";
        Delegate = true;
        KillMode = "process";
        OOMScoreAdjust = -500;
      };
    };

    # Docker setup service (simplified)
    systemd.services.docker-setup = {
      description = "Setup Docker group and user permissions";
      enable = true;
      wantedBy = [ "system-manager.target" ];
      before = [ "docker.service" ];
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

        # Disable system docker service if it exists to avoid conflicts
        if systemctl list-unit-files | grep -q "^docker.service"; then
          echo "Disabling system docker service to avoid conflicts..."
          systemctl disable docker.service || true
          systemctl stop docker.service || true
        fi
        
        # Enable our nix-managed docker service for auto-start
        echo "Enabling nix-managed docker service for auto-start..."
        systemctl enable docker.service || true
      '';
    };
  };
} 