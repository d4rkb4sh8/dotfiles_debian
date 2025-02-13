#!/usr/bin/env bash
flatpak list --app --columns=application >$HOME/dotfiles/flatpaks_list.bak
dconf dump / >$HOME/dotfiles/gnome_backup.bak
