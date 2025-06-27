# Nix Configuration Management Makefile
.PHONY: help home-work home-personal system-setup system-switch system-backup-shells clean status

# Default target
help:
	@echo "🔧 Nix Configuration Management"
	@echo ""
	@echo "Home Manager (User-level):"
	@echo "  make home-work     - Switch to work profile (home-manager)"
	@echo "  make home-personal - Switch to personal profile (home-manager)"
	@echo ""
	@echo "System Manager (System-level):"
	@echo "  make system-setup  - Setup system-level configuration (zsh, tools)"
	@echo "  make system-switch - Re-apply system configuration"
	@echo ""
	@echo "Maintenance:"
	@echo "  make status        - Show current configuration status"
	@echo "  make clean         - Clean up nix generations"
	@echo "  make backup-shells - Backup /etc/shells before system changes"
	@echo ""
	@echo "📋 Current versions managed:"
	@echo "  - Home Manager: User dotfiles, apps, shell integrations"
	@echo "  - System Manager: System packages, default shell, /etc files"

# Home Manager configurations (user-level)
home-work:
	@echo "🏢 Switching to work profile..."
	home-manager switch --flake .#patrik@work

home-personal:
	@echo "🏠 Switching to personal profile..."
	home-manager switch --flake .#patrik@home

# System Manager configurations (system-level)
system-setup: backup-shells
	@echo "🔧 Setting up system-level configuration..."
	@echo "This will:"
	@echo "  - Install zsh, fzf, zoxide, oh-my-posh system-wide"
	@echo "  - Add zsh to /etc/shells"
	@echo "  - Change your default shell to zsh"
	@echo "  - Create systemd services"
	@read -p "Continue? (y/N): " confirm && [ "$$confirm" = "y" ]
	sudo env PATH="$$PATH" nix --extra-experimental-features nix-command --extra-experimental-features flakes run 'github:numtide/system-manager' -- switch --flake '.#default'

system-switch:
	@echo "🔄 Re-applying system configuration..."
	sudo env PATH="$$PATH" nix --extra-experimental-features nix-command --extra-experimental-features flakes run 'github:numtide/system-manager' -- switch --flake '.#default'

# Backup operations
backup-shells:
	@if [ -f /etc/shells ] && [ ! -f /etc/shells.backup ]; then \
		echo "📦 Backing up /etc/shells..."; \
		sudo cp /etc/shells /etc/shells.backup; \
		echo "✅ Backup created at /etc/shells.backup"; \
	else \
		echo "ℹ️  /etc/shells backup already exists or file not found"; \
	fi

# Status and maintenance
status:
	@echo "📊 Current Configuration Status:"
	@echo ""
	@echo "🏠 Home Manager:"
	@home-manager generations | head -5
	@echo ""
	@echo "🖥️  Current Shell: $${SHELL}"
	@echo "🔗 Zsh Location: $$(which zsh 2>/dev/null || echo 'Not found')"
	@echo ""
	@echo "📂 Stow Status:"
	@ls -la ~/.zshrc ~/.config/zsh ~/.config/ohmyposh 2>/dev/null || echo "Stow links not found"
	@echo ""
	@echo "🔧 System Manager:"
	@if command -v system-manager >/dev/null 2>&1; then \
		system-manager --version; \
	else \
		echo "System Manager not installed"; \
	fi

clean:
	@echo "🧹 Cleaning up old generations..."
	@read -p "This will remove old Home Manager generations. Continue? (y/N): " confirm && [ "$$confirm" = "y" ]
	home-manager expire-generations "-7 days"
	nix-collect-garbage -d

# Fix the /etc/shells issue specifically
fix-shells:
	@echo "🔧 Fixing /etc/shells for system-manager..."
	@if [ -f /etc/shells ]; then \
		sudo mv /etc/shells /etc/shells.backup.$(shell date +%Y%m%d_%H%M%S); \
		echo "✅ Moved existing /etc/shells to backup"; \
	fi
	@$(MAKE) system-switch

# Development helpers
build-test:
	@echo "🧪 Testing configuration build..."
	nix build '.#systemConfigs.default' --dry-run

update-flake:
	@echo "⬆️  Updating flake inputs..."
	nix flake update

show-config:
	@echo "📋 Current Flake Configuration:"
	@echo ""
	@echo "Home Configurations:"
	@nix flake show | grep "homeConfigurations"
	@echo ""
	@echo "System Configurations:"  
	@nix flake show | grep "systemConfigs" 