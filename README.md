# NixOS Configuration

This repository contains my NixOS and Home Manager configuration for managing my development environment across different machines.

## 🚀 Quick Setup for New PC

### 1. Install Nix Package Manager
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Enable Flakes (Required)
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 3. Restart your shell
```bash
source /etc/profile.d/nix.sh
```

### 4. Clone this repository
```bash
git clone https://github.com/yourusername/nixos-config.git ~/nixos-config
cd ~/nixos-config
```

### 5. Initialize Home Manager with Flakes
```bash
# For unstable/master branch
nix run home-manager/master -- init --switch

# OR for release-25.05 (more stable)
nix run home-manager/release-25.05 -- init --switch
```

### 6. Switch to your desired profile
```bash
# Work profile (includes WireGuard tools)
home-manager switch --flake .#patrik@work

# Home profile
home-manager switch --flake .#patrik@home

# Default profile
home-manager switch --flake .#patrik
```

## 📦 Available Profiles

- **`patrik@work`**: Work environment with development tools, WireGuard, and minimal personal apps
- **`patrik@home`**: Home environment with personal apps and additional tools
- **`patrik`**: Default profile

## 🔧 Maintenance Commands

### Update packages
```bash
nix flake update
```

### Apply new generation
```bash
home-manager switch --flake .#patrik@work
```

### Rollback to previous generation
```bash
home-manager generations
/nix/store/XXXXXXXXXXXXXXX/activate
```

### Clean up old generations
```bash
nix-collect-garbage -d
```

## 🛠️ What's Included

### Development Tools
- **Languages**: Go, Python, Node.js, Clang
- **Tools**: Git, Neovim, Lazygit, Lazydocker
- **Shell**: Zsh with Oh-My-Posh, FZF, Zoxide
- **Networking**: WireGuard tools

### Applications
- **Editor**: Cursor (with nixGL wrapper for GPU support)
- **Terminal**: Ghostty (with nixGL wrapper)
- **Browser**: Zen Browser (home profile only)

### System Integration
- **Fonts**: DejaVu, Liberation fonts
- **Shell**: Custom zsh configuration with dotfiles integration
- **Environment**: Direnv, SDKMAN integration

## 📝 Notes

- This configuration uses **Nix Flakes** for reproducible builds
- **WireGuard tools** are included in the work profile
- **nixGL wrappers** are used for GPU-accelerated applications on non-NixOS systems
- Configuration integrates with existing dotfiles in `~/dotfiles/`
