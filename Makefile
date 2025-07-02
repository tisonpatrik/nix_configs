# Nix Configuration Management Makefile

# Home Manager configurations (user-level)
.PHONY: home-work
home-work:
	@echo "🏢 Switching to work profile..."
	home-manager switch --flake .#patrik@work

.PHONY: home-personal
home-personal:
	@echo "🏠 Switching to personal profile..."
	home-manager switch --flake .#patrik@home

# System Manager configurations (system-level)
.PHONY: system-setup
system-setup: backup-shells
	@echo "🔧 Setting up system-level configuration..."
	@echo "This will:"
	@echo "  - Install zsh, fzf, zoxide, oh-my-posh system-wide"
	@echo "  - Add zsh to /etc/shells"
	@echo "  - Change your default shell to zsh"
	@echo "  - Create systemd services"
	sudo env PATH="$$PATH" nix --extra-experimental-features nix-command --extra-experimental-features flakes run 'github:numtide/system-manager' -- switch --flake '.#default'

.PHONY: system-switch
system-switch:
	@echo "🔄 Re-applying system configuration..."
	@$(MAKE) unstow
	@$(MAKE) stow-clean
	sudo env PATH="$$PATH" nix --extra-experimental-features nix-command --extra-experimental-features flakes run 'github:numtide/system-manager' -- switch --flake '.#default'

.PHONY: clean
clean:
	@echo "🧹 Cleaning up old generations..."
	home-manager expire-generations "-7 days"
	nix-collect-garbage -d

.PHONY: unstow
unstow:
	@echo "🔗 Removing all stow symlinks..."
	cd stow-dotfiles && stow -D -t ~ zsh ohmyposh fastfetch ghostty 2>/dev/null || true
	@echo "✅ All symlinks removed"

.PHONY: stow-clean
stow-clean:
	@echo "🧹 Cleaning and re-stowing all dotfiles..."
	rm -f ~/.zshrc
	rm -rf ~/.config/zsh ~/.config/ohmyposh ~/.config/fastfetch ~/.config/ghostty
	cd stow-dotfiles && stow -t ~ zsh ohmyposh fastfetch ghostty
	@echo "✅ All dotfiles cleaned and re-stowed"

.PHONY: build-test
build-test:
	@echo "🧪 Testing configuration build..."
	nix build '.#systemConfigs.default' --dry-run

.PHONY: update-flake
update-flake:
	@echo "⬆️  Updating flake inputs..."
	nix flake update

