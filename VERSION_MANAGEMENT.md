# Version Management: Home Manager vs System Manager

## 🏗️ Two-Layer Architecture

Your nix configuration now uses **two complementary tools**:

### 🏠 Home Manager (User-level)
- **What**: Manages user-specific configurations and applications
- **Scope**: Only affects your user account (`/home/patrik`)
- **Permissions**: No sudo required
- **Rollback**: `home-manager generations` and rollback per user

**Manages:**
- Dotfiles symlinked via Stow (`~/.zshrc`, `~/.config/`)
- User applications (cursor, ghostty, signal)
- User shell integrations (but not the default shell)
- Development tools specific to your user

### 🖥️ System Manager (System-level)
- **What**: Manages system-wide configurations and packages
- **Scope**: Affects the entire system (`/etc`, systemd services)
- **Permissions**: Requires sudo
- **Rollback**: System-manager generations and system-wide rollback

**Manages:**
- System packages available to all users
- `/etc/shells` (which shells are valid for the system)
- Default user shell changes (`chsh`)
- System-wide systemd services

## 🔄 Version Management Strategy

### Current Setup Commands:

```bash
# User-level changes (fast, no sudo)
make home-work          # Switch to work environment
make home-personal      # Switch to personal environment

# System-level changes (requires sudo)
make system-setup       # Initial system setup
make fix-shells         # Fix the /etc/shells conflict we hit

# Status and maintenance
make status            # Show everything
make clean             # Clean old generations
```

## 🆚 Comparison: Before vs After

### ❌ Before (Pure Home Manager)
```bash
# Problems we had:
- Hardcoded paths: ~/repos/personal/nix-config/dotfiles/...
- Shell still bash (no system-level shell change)
- Dotfiles not loading (shell mismatch)
- Complex path management
```

### ✅ After (Home Manager + System Manager + Stow)
```bash
# Benefits:
- Clean symlinks via Stow: ~/.zshrc -> stow-dotfiles/zsh/.zshrc  
- System-wide zsh installation
- Proper shell change via systemd service
- Modular configuration (user vs system)
- Portable dotfiles (no hardcoded paths)
```

## 🔧 How Updates Work

### Daily Workflow:
1. **Edit configs**: Modify files in `stow-dotfiles/`
2. **User changes**: `make home-work` (fast, frequent)
3. **System changes**: `make system-switch` (slow, rare)

### Update Scenarios:

| What you're changing | Command to use | Speed | Sudo needed |
|---------------------|----------------|-------|-------------|
| Aliases, functions, prompt | Just edit files in `stow-dotfiles/` | Instant | No |
| User apps (cursor, signal) | `make home-work` | Fast (~30s) | No |
| Add new dotfile type | Edit + `make home-work` | Fast | No |
| System packages | Edit `system.nix` + `make system-switch` | Slow (~2min) | Yes |
| Shell configuration | Edit `system.nix` + `make system-switch` | Slow | Yes |

### Version Control:
- **Home Manager**: Multiple profiles (work/personal)
- **System Manager**: Single system config
- **Both**: Nix generations for rollback

## 🎯 Next Steps

Run this to fix the current issue and complete setup:
```bash
make fix-shells
```

This will:
1. Backup your current `/etc/shells`
2. Let system-manager manage it properly
3. Change your default shell to zsh
4. Complete the system setup

After that, your workflow becomes:
- `make home-work` / `make home-personal` for daily switching
- `make status` to check everything
- Edit files in `stow-dotfiles/` for config changes 