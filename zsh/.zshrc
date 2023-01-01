# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
plugins=(docker git kubectl z)
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

# PATH variable
export PATH=/opt/homebrew/bin:$PATH
export PATH=~/.local/bin:$PATH


# ENV variables
export GPG_TTY=$(tty)

# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh