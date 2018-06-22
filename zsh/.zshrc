# oh-my-zsh
export ZSH=/Users/spren9er/.oh-my-zsh
ZSH_THEME="blinks"
plugins=(git bundler ruby rvm rails docker docker-machine docker-compose)
source $ZSH/oh-my-zsh.sh

# key binding
bindkey \^U backward-kill-line

# misc
export BUNDLE_EDITOR="atom --wait"
