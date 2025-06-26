# Pop!_OS Configuration

This repository contains my Home Manager configuration for managing my development environment on Pop!_OS.

## 🚀 Quick Setup for New PC

### 1. Install Nix Package Manager

#### Option A: Determinate Nix (Recommended)
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
```

**Note**: This installs Determinate Nix with flakes enabled by default. If you prefer upstream Nix, use:
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

### 2. Restart your shell
```bash
source /etc/profile.d/nix.sh
```

### 3. Clone this repository
```bash
git clone https://github.com/yourusername/nixos-config.git ~/nixos-config
cd ~/nixos-config
```

### 4. Initialize Home Manager with Flakes
```bash
# For unstable/master branch
nix run home-manager/master -- init --switch

# OR for release-25.05 (more stable)
nix run home-manager/release-25.05 -- init --switch
```

### 5. Switch to your desired profile
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

### Upgrade Nix (if using Determinate Nix)
```bash
sudo determinate-nixd upgrade
```

### Upgrade Nix (if using upstream Nix)
```bash
sudo -i nix upgrade-nix
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
- **Determinate Nix Installer** enables flakes by default, so no manual configuration is needed
- **WireGuard tools** are included in the work profile
- **nixGL wrappers** are used for GPU-accelerated applications on Pop!_OS
- Configuration integrates with existing dotfiles in `~/dotfiles/`

## 🔧 Troubleshooting

### Non-interactive installation
If you need to install without confirmation prompts:
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
```

### Container/Docker environments
For containers without systemd, use:
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install linux --init none --no-confirm
```

### WSL2 without systemd
If you can't enable systemd in WSL2:
```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install linux --init none
```
**Note**: When using `--init none`, only root can run Nix commands with `sudo -i nix run nixpkgs#hello`
