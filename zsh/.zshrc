# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="blinks"
plugins=(git bundler ruby rvm rails docker docker-machine docker-compose)
source $ZSH/oh-my-zsh.sh

# key bindings
bindkey \^U backward-kill-line

# misc
export LANG=en_US.UTF-8
export EDITOR="atom --wait"

# development
c() { cd ~/Development/$1; }
_c() { _files -W ~/Development -/; }
compdef _c c

# git
alias gpl='ggpull'
alias gph='ggpush'
alias gc='git commit -m'
compdef _git gc=git-commit
