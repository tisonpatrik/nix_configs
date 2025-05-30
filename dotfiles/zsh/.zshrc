# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

#bin path
export PATH="$HOME/.fzf/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::ubuntu

zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'

alias normi='norminette -R CheckForbiddenSourceHeader'


# Shell integrations

if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
  source "$(fzf-share)/completion.zsh"
fi

## eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

alias mini='~/mini-moulinette/mini-moul.sh'


export PATH="$HOME/bin:$PATH"

function cursor {
	nohup /home/patrik/Applications/cursor.appimage "$@" > /dev/null 2>&1 & disown
}

function docker_purge {
  echo "Purging Docker system completely..."
  docker container rm -f $(docker container ls -aq 2>/dev/null) 2>/dev/null
  docker image rm -f $(docker image ls -aq 2>/dev/null) 2>/dev/null
  docker volume rm -f $(docker volume ls -q 2>/dev/null) 2>/dev/null
  docker network rm $(docker network ls -q | grep -v '^bridge$\|^host$\|^none$') 2>/dev/null
  echo "Done."
}



[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


alias awslog='aws sso login --profile infra1 && aws --profile infra1 ecr get-login-password | docker login --username AWS --password-stdin 020413372491.dkr.ecr.us-east-1.amazonaws.com'
export COMPOSE_PROFILES=ai

function renew_code_artifact {
    export CODEARTIFACT_AUTH_TOKEN="$(aws codeartifact get-authorization-token --profile infra1 --domain infra1 --domain-owner 020413372491 --region us-east-1 --query authorizationToken --output text)"
    echo $CODEARTIFACT_AUTH_TOKEN | tee ~/.gradle/.codeartifact-token
}

alias prepare_to_develop='aws sso login --profile infra1 && aws --profile infra1 ecr get-login-password | docker login --username AWS --password-stdin 020413372491.dkr.ecr.us-east-1.amazonaws.com && renew_code_artifact'
