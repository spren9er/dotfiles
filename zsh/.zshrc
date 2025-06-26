# PATH variable
export PATH=/opt/homebrew/bin:$PATH
export PATH=~/.local/bin:$PATH

# ENV variables
export GPG_TTY=$(tty)

# misc
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export EDITOR="code --wait"

# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
plugins=(docker git kubectl z)
source $ZSH/oh-my-zsh.sh

# development folder
c() { cd ~/Development/$1; }
_c() { _files -W ~/Development -/; }
compdef _c c

# key bindings
bindkey \^U backward-kill-line

# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh