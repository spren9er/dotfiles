# powerlevel10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
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

# powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh