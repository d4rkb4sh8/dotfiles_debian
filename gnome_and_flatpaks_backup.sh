#!/usr/bin/env bash
flatpak list --app --columns=application >$HOME/dotfiles/flatpaks_list.txt
dconf dump / >$HOME/dotfiles/gnome_backup
