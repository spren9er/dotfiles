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
