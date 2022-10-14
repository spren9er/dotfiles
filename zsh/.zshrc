# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
plugins=(bundler docker git kubectl zsh-z)
source $ZSH/oh-my-zsh.sh

# key bindings
bindkey \^U backward-kill-line

# misc
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export EDITOR="code --wait"

# development folder
c() { cd ~/Development/$1; }
_c() { _files -W ~/Development -/; }
compdef _c c