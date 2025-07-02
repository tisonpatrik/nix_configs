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
	@read -p "Continue? (y/N): " confirm && [ "$$confirm" = "y" ]
	sudo env PATH="$$PATH" nix --extra-experimental-features nix-command --extra-experimental-features flakes run 'github:numtide/system-manager' -- switch --flake '.#default'

.PHONY: system-switch
system-switch:
	@echo "🔄 Re-applying system configuration..."
	sudo env PATH="$$PATH" nix --extra-experimental-features nix-command --extra-experimental-features flakes run 'github:numtide/system-manager' -- switch --flake '.#default'

.PHONY: clean
clean:
	@echo "🧹 Cleaning up old generations..."
	@read -p "This will remove old Home Manager generations. Continue? (y/N): " confirm && [ "$$confirm" = "y" ]
	home-manager expire-generations "-7 days"
	nix-collect-garbage -d

.PHONY: build-test
build-test:
	@echo "🧪 Testing configuration build..."
	nix build '.#systemConfigs.default' --dry-run

.PHONY: update-flake
update-flake:
	@echo "⬆️  Updating flake inputs..."
	nix flake update

