# spren9er dotfiles

Configuration Settings of macOS Development Environment

## Atom

Archiving a list of packages is done via

```bash
apm list --installed --bare | grep '^[^@]\+' -o > ~/.dotfiles/atom/packages.list
```
Installing all packages from list can be done by

```bash
apm install --packages-file ~/.dotfiles/atom/packages.list
```

## Symlinking

```bash
ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/git/.gitignore_global ~/.gitignore_global
ln -s ~/.dotfiles/git/.gitmessage ~/.gitmessage
ln -s ~/.dotfiles/atom ~/.atom
ln -s ~/.dotfiles/hyper/hyper.js ~/.hyper.js
ln -s ~/.dotfiles/r/.Rprofile ~/.Rprofile
ln -s ~/.dotfiles/guard/.guard.rb ~/.guard.rb
```
