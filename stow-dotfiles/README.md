# Stow-based Dotfiles Management

This directory contains dotfiles managed by GNU Stow for clean, symlink-based configuration management.

## 🎯 Benefits of Stow

- **Fully Automatic**: Runs automatically when you `home-manager switch`
- **No hardcoded paths**: No more `$HOME/repos/personal/nix-config/dotfiles/...`
- **Portable**: Works on any machine with Stow installed
- **Zero configuration**: No manual commands needed
- **Clean**: Symlinks are created automatically in the right locations
- **Versioned**: All configurations are tracked in git
- **Modular**: Easy to add/remove different application configs

## 📁 Structure

```
stow-dotfiles/
├── zsh/
│   ├── .zshrc                    # Main zsh config (symlinks to ~/.zshrc)
│   └── .config/zsh/zshrc/        # Modular zsh configs (symlinks to ~/.config/zsh/zshrc/)
│       ├── 00_init
│       ├── 01_setup
│       ├── 02_functions
│       ├── 03_sdkman
│       ├── gooddata
│       └── school_42
└── ohmyposh/
    └── .config/ohmyposh/         # Oh-my-posh themes (symlinks to ~/.config/ohmyposh/)
        ├── base.json
        └── zen.toml
```

## 🚀 Setup

**Fully automatic!** Just run:
```bash
home-manager switch --flake .#patrik@home  # or @work
```

That's it! The Home Manager activation script will:
1. Install Stow
2. Automatically run `stow -t ~ zsh ohmyposh` 
3. Create all the necessary symlinks

**Verify the symlinks**:
```bash
ls -la ~/.zshrc ~/.config/zsh ~/.config/ohmyposh
```

## 🔧 Managing Configurations

### Adding new configurations
1. Create a new directory in `stow-dotfiles/` (e.g., `nvim/`)
2. Structure it as it should appear in `$HOME` (e.g., `nvim/.config/nvim/`)
3. Run: `cd stow-dotfiles && stow -t ~ nvim`

### Removing configurations
```bash
cd stow-dotfiles
stow -D -t ~ zsh        # Remove zsh symlinks
stow -D -t ~ ohmyposh   # Remove ohmyposh symlinks
```

### Updating configurations
Just edit the files in `stow-dotfiles/` - changes are immediately reflected since they're symlinked!

## 🎨 Current Configurations

- **zsh**: Complete zsh setup with modular configuration loading
- **ohmyposh**: Prompt themes and configurations

## 🔄 Migration from Old Structure

The old hardcoded paths in:
- `hosts/work/zsh.nix`
- `hosts/home/home.nix`

Have been updated to simply source `~/.zshrc` (which is now a Stow-managed symlink).

## 🤖 Automatic Activation

Both work and home configurations now include a `home.activation` script that:
- Runs after Home Manager processes all other configuration
- Checks if the `stow-dotfiles` directory exists
- Automatically runs `stow -t ~ zsh ohmyposh` 
- Handles errors gracefully (won't fail if already stowed)

This means your dotfiles are always in sync with your Home Manager configuration!

## 📝 Notes

- The `.zshrc` now loads configurations from `~/.config/zsh/zshrc/` instead of the old hardcoded path
- All existing functionality is preserved
- Much cleaner and more maintainable than hardcoded paths
- Easy to add new dotfiles for other applications
- We use `-t ~` to target the home directory (instead of the default parent directory)
- Stow automatically handles backup of existing files and conflict resolution 