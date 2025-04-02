#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status and enable pipefail
set -euo pipefail

# Function to log messages with a timestamp
log() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Section: Initial Setup
log "Starting initial setup..."
sudo apt update -y
sudo apt install -y git gh curl gawk cmake wget make stow build-essential procps file
sudo sed -i '/^deb / s/$/ contrib non-free/' /etc/apt/sources.list
sudo apt update -y

# Section: Remove Bloatware (customize list as needed)
log "Removing bloatware..."
sudo apt purge -y audacity gimp gnome-games libreoffice* || log "Some packages not found; continuing..."

# Section: Git Projects and Dotfiles Setup
log "Setting up gitprojects and dotfiles..."
mkdir -p "$HOME/gitprojects"
if [ ! -d "$HOME/gitprojects/notes" ]; then
  git clone https://github.com/d4rkb4sh8/notes.git "$HOME/gitprojects/notes" || log "Failed to clone notes repo"
fi
if [ ! -d "$HOME/dotfiles" ]; then
  git clone https://github.com/d4rkb4sh8/dotfiles.git "$HOME/dotfiles" || log "Failed to clone dotfiles repo"
fi
if [ -d "$HOME/dotfiles" ]; then
  cd "$HOME/dotfiles" && stow --adopt . && git restore .
  cp -r "$HOME/dotfiles/wallpapers" "$HOME/Pictures" || log "Wallpapers copy failed"
fi

# Section: Install APT Packages
log "Installing APT packages..."
sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
if [ -f "$HOME/dotfiles/apt_list.bak" ]; then
  xargs -a "$HOME/dotfiles/apt_list.bak" sudo apt install -y
else
  log "apt_list.bak not found, skipping APT package installs"
fi

# Section: Flatpak and Snap Setup
log "Setting up Flatpak and Snap..."
sudo apt install -y snapd flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
if [ -f "$HOME/dotfiles/snap_list.bak" ]; then
  xargs -a "$HOME/dotfiles/snap_list.bak" sudo snap install
else
  log "snap_list.bak not found, skipping Snap installs"
fi

# Section: ble.sh Installation
log "Installing ble.sh..."
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git "$HOME/ble.sh"
make -C "$HOME/ble.sh" install PREFIX="$HOME/.local"
echo '[[ $- == *i* ]] && source "$HOME/.local/share/blesh/ble.sh"' >>"$HOME/.bashrc"

# Section: Font Installation
log "Installing Hack Nerd Font..."
mkdir -p "$HOME/.local/share/fonts"
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip -O /tmp/Hack.zip
unzip -q /tmp/Hack.zip -d "$HOME/.local/share/fonts"
fc-cache -fv

# Section: UFW Setup
log "Setting up UFW..."
sudo ufw limit 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw --force enable

# Section: Homebrew Setup
log "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>"$HOME/.bashrc"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
ulimit -n 8192

if [ -f "$HOME/dotfiles/brew_list.bak" ]; then
  xargs -a "$HOME/dotfiles/brew_list.bak" brew install
else
  log "brew_list.bak not found, skipping Homebrew installs"
fi

# Section: Rust Installation
log "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# Section: Icon Theme Installation
log "Installing Tela-circle-icons..."
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git "$HOME/Downloads/Tela-circle-icon-theme"
"$HOME/Downloads/Tela-circle-icon-theme/install.sh"

# Section: GRC Colors Setup
log "Setting up GRC colors..."
cd "$HOME/gitprojects"
git clone https://github.com/garabik/grc.git
cd grc
sudo ./install.sh
sudo cp /usr/local/etc/grc.conf /etc/grc.conf

# Section: Starship Prompt Setup
log "Setting up Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y
starship preset nerd-font-symbols -o ~/.config/starship.toml

# Section: GRUB Custom Theme Installation
log "Installing Grub theme..."
if [ -f "$HOME/Pictures/wallpapers/wallpaper_001.jpg" ]; then
  cp "$HOME/Pictures/wallpapers/wallpaper_001.jpg" "$HOME/gitprojects/grub2-themes/background.jpg"
fi
sudo "$HOME/gitprojects/grub2-themes/install.sh" -s 1080p -b -t whitesur

# Section: GRUB Configuration
log "Configuring GRUB..."
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/' /etc/default/grub
sudo update-grub
sudo update-initramfs -u -k all

# Section: Flatpak Applications Installation
log "Installing Flatpak applications..."
if [ -f "$HOME/dotfiles/flatpaks_list.bak" ]; then
  xargs -a "$HOME/dotfiles/flatpaks_list.bak" flatpak install -y flathub
else
  log "flatpaks_list.bak not found, skipping Flatpak installs"
fi

# Section: Cargo Installations
log "Installing cargo packages..."
cargo install cargo-update cargo-list kanata binsider

# Section: tgpt and Atuin Installation
log "Installing tgpt and atuin..."
curl -sSL https://raw.githubusercontent.com/aandrew-me/tgpt/main/install | sudo bash -s /usr/local/bin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# Section: Ollama Installation
log "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# Section: Final Update and Cleanup
log "Final update and cleanup..."
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y

# Section: Source .bashrc and Restore Gnome Settings
log "Sourcing .bashrc and restoring Gnome settings..."
# shellcheck source=/dev/null
source "$HOME/.bashrc"
if [ -f "$HOME/dotfiles/gnome_settings.bak" ]; then
  dconf load / <"$HOME/dotfiles/gnome_settings.bak"
fi

# Section: AppArmor Enforcement
log "Enforcing AppArmor profiles..."
sudo aa-enforce /etc/apparmor.d/*

# Section: Display Completion Message and Reboot
log "Displaying completion message and rebooting..."
command_exists figlet && command_exists lolcat && figlet h4ck3r m4ch1n3 | lolcat || log "Install figlet and lolcat for fancy display"
sudo reboot
