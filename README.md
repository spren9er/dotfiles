# spren9er dotfiles

Configuration Settings of macOS Development Environment

## Export

### Visual Studio Code Extensions

Exporting a list of all extensions

```bash
code --list-extensions > ~/.dotfiles/vscode/extensions.txt
```

## Import

First, clone git repository

```bash
git clone git@github.com:spren9er/dotfiles.git ~/.dotfiles
```

Import configuration files selectively by creating some/all of the following
symlinks:

### Git

```bash
ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/git/.gitignore_global ~/.gitignore_global
ln -s ~/.dotfiles/git/.gitmessage ~/.gitmessage
```

### Visual Studio Code

```bash
ln -s ~/.dotfiles/vscode/settings.json \
  ~/Library/Application\ Support/Code/User/settings.json
ln -s ~/.dotfiles/vscode/keybindings.json \
  ~/Library/Application\ Support/Code/User/keybindings.json
ln -s ~/.dotfiles/vscode/snippets/ ~/Library/Application\ Support/Code/User
```

### GPG

```bash
mkdir ~/.gnupg
chmod 600 ~/.gnupg/*
chmod 700 ~/.gnupg
ln -s ~/.dotfiles/gpg/gpg.conf ~/.gnupg/gpg.conf
ln -s ~/.dotfiles/gpg/gpg-agent.conf ~/.gnupg/gpg-agent.conf
```

### Warp

Warp can't detect symlinks (yet). Instead, copy launch configuration files via

```bash
cp -r ~/.dotfiles/warp/launch_configurations/* ~/.warp/launch_configurations
```

### visidata

```bash
ln -s ~/.dotfiles/visidata/.visidatarc ~/.visidatarc
```

### iPython

```bash
ln -s ~/.dotfiles/python/.ipython/profile_default/startup \
  ~/.ipython/profile_default/startup
```

### Prettier

```bash
ln -s ~/.dotfiles/prettier/.prettierrc ~/.prettierrc
```