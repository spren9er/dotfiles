# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="blinks"
plugins=(git bundler ruby rails docker docker-machine docker-compose)
source $ZSH/oh-my-zsh.sh

# key bindings
bindkey \^U backward-kill-line

# misc
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export EDITOR="atom --wait"

# development folder
c() { cd ~/Development/$1; }
_c() { _files -W ~/Development -/; }
compdef _c c
