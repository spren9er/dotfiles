# PATH variable
export PATH=/opt/homebrew/bin:$PATH
export PATH=~/.local/bin:$PATH

# ENV variables
export GPG_TTY=$(tty)
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export EDITOR=nvim

# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
plugins=(docker git z)
source $ZSH/oh-my-zsh.sh

# key bindings
bindkey \^U backward-kill-line
