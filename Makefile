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


.PHONY: system-switch
system-switch:
	@echo "🔄 Re-applying system configuration..."
	@$(MAKE) unstow
	@$(MAKE) stow-clean
	@$(MAKE) system-apply
	@$(MAKE) stow-dotfiles

.PHONY: system-apply
system-apply:
	sudo env PATH="$$PATH" nix --extra-experimental-features nix-command --extra-experimental-features flakes run 'github:numtide/system-manager' -- switch --flake '.#default'

.PHONY: clean
clean:
	@echo "🧹 Cleaning up old generations..."
	home-manager expire-generations "-7 days"
	nix-collect-garbage -d 

.PHONY: unstow
unstow:
	@echo "🔗 Removing all stow symlinks..."
	@if command -v stow >/dev/null 2>&1; then \
		cd stow-dotfiles && stow -D -t ~ zsh ohmyposh fastfetch ghostty 2>/dev/null || true; \
		echo "✅ All symlinks removed"; \
	else \
		echo "⚠️  stow not found, skipping symlink removal"; \
	fi

.PHONY: stow-clean
stow-clean:
	@echo "🧹 Cleaning and re-stowing all dotfiles..."
	rm -f ~/.zshrc
	rm -rf ~/.config/zsh ~/.config/ohmyposh ~/.config/fastfetch ~/.config/ghostty
	@if command -v stow >/dev/null 2>&1; then \
		cd stow-dotfiles && stow -t ~ zsh ohmyposh fastfetch ghostty; \
		echo "✅ All dotfiles cleaned and re-stowed"; \
	else \
		echo "⚠️  stow not found, skipping dotfile stowing"; \
		echo "💡 Run 'make system-switch' again after stow is installed"; \
	fi

.PHONY: build-test
build-test:
	@echo "🧪 Testing configuration build..."
	nix build '.#systemConfigs.default' --dry-run

.PHONY: update-flake
update-flake:
	@echo "⬆️  Updating flake inputs..."
	nix flake update

.PHONY: stow-dotfiles
stow-dotfiles:
	@echo "🔗 Setting up dotfiles with Stow..."
	@if [ -d "$$HOME/repos/personal/nix-config/stow-dotfiles" ]; then \
		cd $$HOME/repos/personal/nix-config/stow-dotfiles; \
		rm -f $$HOME/.zshrc; \
		rm -rf $$HOME/.config/zsh; \
		rm -rf $$HOME/.config/ohmyposh; \
		rm -rf $$HOME/.config/fastfetch; \
		rm -rf $$HOME/.config/ghostty; \
		if command -v stow >/dev/null 2>&1; then \
			stow -t $$HOME zsh ohmyposh fastfetch ghostty 2>/dev/null || true; \
			echo "✅ Dotfiles stowed successfully"; \
		else \
			echo "⚠️  stow not found, skipping dotfile stowing"; \
		fi \
	else \
		echo "⚠️  Stow dotfiles directory not found, skipping setup"; \
	fi

