#!/usr/bin/env bash

#gnome settings
dconf dump / >$HOME/dotfiles_debian/gnome_settings.bak

#flatpaks_list
flatpak list --app --columns=application >$HOME/dotfiles_debian/flatpaks_list.bak

# brew list
brew list -1 >$HOME/dotfiles_debian/brew_list.bak

#snap list
snap list | awk 'NR>1{print $1}' >$HOME/dotfiles_debian/snap_list.bak
