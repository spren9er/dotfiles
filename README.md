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

### Git

```bash
ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/git/.gitignore_global ~/.gitignore_global
ln -s ~/.dotfiles/git/.gitmessage ~/.gitmessage
```

### Atom

```bash
ln -s ~/.dotfiles/atom ~/.atom
```

### Hyper Terminal

```bash
ln -s ~/.dotfiles/hyper/hyper.js ~/.hyper.js
```

### R Profile

```bash
ln -s ~/.dotfiles/r/.Rprofile ~/.Rprofile
```

### Guard

```bash
ln -s ~/.dotfiles/guard/.guard.rb ~/.guard.rb
```

### Visual Studio Code

```bash
ln -s ~/.dotfiles/vscode/settings.json \
  ~/Library/Application\ Support/Code/User/settings.json
ln -s ~/.dotfiles/vscode/keybindings.json \
  ~/Library/Application\ Support/Code/User/keybindings.json
ln -s ~/.dotfiles/vscode/snippets/ ~/Library/Application\ Support/Code/User
```

### iPython

```bash
ln -s ~/.dotfiles/python/.ipython/profile_default/startup \
  ~/.ipython/profile_default/startup
```

### GPG

```bash
ln -s ~/.dotfiles/gpg/gpg.conf ~/.gnupg/gpg.conf
```
