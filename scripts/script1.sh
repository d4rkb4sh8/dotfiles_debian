#!/bin/bash

# This script aims to detect and capture current system configurations 
# for Debian Linux on GNOME running Wayland, and then generate a 
# reproducible setup script.

# 1. Define Variables
USER_CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$HOME/dotfiles" 

# 2. Install Required Packages
sudo apt update
sudo apt install -y git 
sudo apt install -y stow
sudo apt install -y dconf-editor 

# 3. Create Dotfiles Repository (if it doesn't exist)
if [ ! -d "$DOTFILES_DIR" ]; then
  git init --bare "$DOTFILES_DIR"
fi

# 4. Capture System Configurations
# 4.1 GNOME Extensions
INSTALLED_EXTENSIONS=$(gnome-extensions list | awk '{print $1}' | tr '\n' ' ')

# 4.2 GNOME Tweaks
CURRENT_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme | cut -d "'" -f2)
CURRENT_WM_THEME=$(gsettings get org.gnome.desktop.wm.preferences theme | cut -d "'" -f2)
CURRENT_ICONS=$(gsettings get org.gnome.desktop.interface icon-theme | cut -d "'" -f2)
CURRENT_CURSOR_THEME=$(gsettings get org.gnome.desktop.wm.preferences cursor-theme | cut -d "'" -f2)

# 4.3 Keybindings
# Capture all keybindings
KEYBINDINGS=$(gsettings list-recursively org.gnome.desktop.wm.keybindings | grep -v 'default:' | awk '{print $1,$2}' | sed 's/org.gnome.desktop.wm.keybindings\///g')

# 4.4 GTK Theme
CURRENT_GTK_THEME=$(gtk-theme-selector get-theme)

# 4.5 Wallpaper
CURRENT_WALLPAPER=$(gsettings get org.gnome.desktop.background picture-uri | cut -d "'" -f2)

# 4.6 Installed Packages (apt)
INSTALLED_APT_PACKAGES=$(apt list --installed | awk '{print $1}' | tr '\n' ' ')

# 4.7 Installed Packages (brew)
if command -v brew &> /dev/null; then
  INSTALLED_BREW_PACKAGES=$(brew list)
else
  INSTALLED_BREW_PACKAGES=""
fi

# 4.8 Installed Packages (cargo)
if command -v cargo &> /dev/null; then
  INSTALLED_CARGO_PACKAGES=$(cargo-list list | awk '{print $1}' | tr '\n' ' ')
else
  INSTALLED_CARGO_PACKAGES=""
fi

# 4.9 Installed Packages (pipx)
if command -v pipx &> /dev/null; then
  INSTALLED_PIPX_PACKAGES=$(pipx list | awk '{print $1}' | tr '\n' ' ')
else
  INSTALLED_PIPX_PACKAGES=""
fi

# 4.10 Installed Packages (flatpak)
if command -v flatpak &> /dev/null; then
  INSTALLED_FLATPAK_PACKAGES=$(flatpak list --app | awk '{print $3}' | tr '\n' ' ')
else
  INSTALLED_FLATPAK_PACKAGES=""
fi

# 4.11 Installed Packages (snap)
if command -v snap &> /dev/null; then
  INSTALLED_SNAP_PACKAGES=$(snap list | awk '{print $1}' | tr '\n' ' ')
else
  INSTALLED_SNAP_PACKAGES=""
fi

# 4.12 Capture Terminator Configuration
if [ -f "$HOME/.config/terminator/config" ]; then
  TERMINATOR_CONFIG=$(cat "$HOME/.config/terminator/config")
else
  TERMINATOR_CONFIG=""
fi

# 4.13 Capture .bashrc
if [ -f "$HOME/.bashrc" ]; then
  BASHRC_CONFIG=$(cat "$HOME/.bashrc")
else
  BASHRC_CONFIG=""
fi

# 4.14 Capture .bash_aliases
if [ -f "$HOME/.bash_aliases" ]; then
  BASH_ALIASES_CONFIG=$(cat "$HOME/.bash_aliases")
else
  BASH_ALIASES_CONFIG=""
fi

# 5. Generate Setup Script
cat > setup_gnome.sh << EOF
