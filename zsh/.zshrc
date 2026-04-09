#!/usr/bin/env zsh

# ============================================
# ENVIRONMENT
# ============================================

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

HOMEBREW_PREFIX="/opt/homebrew"
BUN_INSTALL="$HOME/.bun"
LOCAL_BIN="$HOME/.local/bin"

mkdir -p "$XDG_CONFIG_HOME/zsh"
mkdir -p "$LOCAL_BIN"

# ============================================
# HISTORY
# ============================================

HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTFILE="$XDG_CONFIG_HOME/zsh/.zsh_history"

setopt APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_SPACE HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS HIST_EXPIRE_DUPS_FIRST

# ============================================
# ZINIT
# ============================================

ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"

# ============================================
# PLUGINS
# ============================================

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-history-substring-search

zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# ============================================
# COMPLETION
# ============================================

autoload -Uz compinit
compinit -C -i
zinit cdreplay -q

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

# ============================================
# KEYBINDINGS
# ============================================

bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ============================================
# FUNCTIONS
# ============================================

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

mkcd() {
  mkdir -p "$1" && cd "$1"
}

port() {
  lsof -i :$1
}

killport() {
  kill -9 $(lsof -t -i:$1)
}

# ============================================
# PATH
# ============================================

add_to_path() {
  if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

add_to_path "$LOCAL_BIN"
add_to_path "$BUN_INSTALL/bin"
add_to_path "$HOMEBREW_PREFIX/bin"

# ============================================
# SHELL INTEGRATIONS
# ============================================

if command_exists starship; then
  eval "$(starship init zsh)"
fi

if command_exists fzf; then
  eval "$(fzf --zsh)"
fi

if command_exists zoxide; then
  eval "$(zoxide init zsh)"
fi

# ============================================
# SYNTAX HIGHLIGHTING (LAST)
# ============================================

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ============================================
# ALIASES
# ============================================

alias c='clear'
alias cc='clear'
alias cls='clear'
alias reload='source ~/.zshrc'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

if command_exists eza; then
  alias ls='eza --icons'
  alias ll='eza -la --icons --git'
  alias lt='eza --tree --icons --level=2'
fi

# ============================================
# GIT
# ============================================

alias g='git'
alias gst='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gca='git commit -am'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias glog='git log --oneline --graph --decorate'

# ============================================
# DOCKER
# ============================================

alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpa='docker ps -a'
alias dk='docker kill $(docker ps -q)'
alias dstop='docker stop $(docker ps -q)'
alias drm='docker rm $(docker ps -aq)'
alias dclean='docker system prune -af'
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dclogs='docker compose logs -f'

# ============================================
# GO
# ============================================

alias gg='go run main.go'
alias gf='go fmt ./...'
alias gt='go test ./...'
alias gb='go build'

# ============================================
# FZF
# ============================================

alias f='fzf'

# ============================================
# PORT / PROCESS
# ============================================

alias ports='lsof -i -P | grep LISTEN'
alias psg='ps aux | grep -v grep | grep'
alias pk='pkill -f'

# ============================================
# UTILITIES
# ============================================

alias ip='curl ifconfig.me'
alias weather='curl wttr.in'
alias serve='python3 -m http.server'
alias update='brew update && brew upgrade && brew cleanup'

# ============================================
# STARTUP
# ============================================

# ============================================
# OPTIONS
# ============================================

setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS CORRECT
unsetopt BEEP

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
unsetopt correct_all
unsetopt correct

# Added by bifrost installer
export PATH="$HOME/.bifrost/bin:$PATH"
