# Patrik's Nix Configuration

Personal Nix configuration for Pop!_OS development environment using Home Manager + System Manager + GNU Stow.

## 🎯 Quick Start

```bash
# Daily workflow - switch between environments
make home-work          # Work environment
make home-personal      # Personal environment

# Check status
make status

# One-time system setup (if shell isn't zsh yet)
make fix-shells
```

## 🛠️ Maintenance

```bash
make clean           # Remove old generations
make update-flake    # Update all packages
make build-test      # Test configuration before applying
make show-config     # Show available configurations
```

## 🔍 Troubleshooting

### Home Manager issues?
```bash
home-manager generations       # Check previous generations
home-manager rollback         # Rollback if needed
```

### System Manager issues?
```bash
make fix-shells               # Fix shell configuration
sudo systemctl status system-manager.target  # Check services
```
