#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to log messages with a timestamp
log() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"
}

# Section: Initial Setup
log "Starting initial setup..."
sudo apt install -y git gh curl gawk cmake
sudo sed -i '/^deb / s/$/ contrib non-free/' /etc/apt/sources.list

# Section: Remove Bloatware
log "Removing bloatware..."
sudo apt purge -y audacity gimp gnome-games libreoffice*
#
# Section: Git Projects and Dotfiles Setup
log "Setting up gitprojects and dotfiles..."
mkdir -p $HOME/gitprojects
git clone https://github.com/d4rkb4sh8/notes.git $HOME/gitprojects/notes
git clone https://github.com/d4rkb4sh8/dotfiles.git $HOME/dotfiles
cd $HOME/dotfiles && stow --adopt . && git restore .
cp -r $HOME/dotfiles/wallpapers $HOME/Pictures

# Section: Install APT Packages
log "Installing APT packages..."
sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
sudo apt install $(cat $HOME/dotfiles/apt_list.bak)

# Section: Flatpak and Snap Setup
log "Setting up Flatpak and Snap..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo snap install snapd snap-store
snap install $(cat $HOME/dotfiles/snap_list.bak)

# Section: ble.sh Installation
log "Installing ble.sh..."
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git $HOME/ble.sh
make -C $HOME/ble.sh install PREFIX=~/.local
echo 'source ~/.local/share/blesh/ble.sh' >>~/.bashrc

# Section: Font Installation
log "Installing Hack Nerd Font..."
mkdir -p ~/.local/share/fonts
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip -O /tmp/Hack.zip
unzip -q /tmp/Hack.zip -d ~/.local/share/fonts
fc-cache -fv

# Section: UFW Setup
log "Setting up UFW..."
sudo ufw limit 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# Section: Homebrew Setup
log "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Increase the file descriptor limit to avoid "too many open files" error
log "Increasing file descriptor limit for Homebrew..."
ulimit -n 8192 # Increase the limit to 8192 (or higher if needed)

brew install gcc $(cat $HOME/dotfiles/brew_list.bak)

# Section: Rust Installation
log "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Section: Icon Theme Installation
log "Installing Tela-circle-icons..."
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git $HOME/Downloads/Tela-circle-icon-theme
$HOME/Downloads/Tela-circle-icon-theme/install.sh

# Section: GRC Colors Setup
log "Setting up GRC colors..."
cd $HOME/gitprojects
git clone https://github.com/garabik/grc.git
cd $HOME/gitprojects/grc
sudo ./install.sh
sudo cp /etc/profile.d/grc.sh /etc

# Section: Starship Prompt Setup
log "Setting up Starship..."
curl -sS https://starship.rs/install.sh | sh
starship preset nerd-font-symbols -o ~/.config/starship.toml

# Section: GRUB Custom Theme Installation
log "Installing Grub theme..."
git clone https://github.com/vinceliuice/grub2-themes.git $HOME/gitprojects/grub2-themes
cp $HOME/Pictures/wallpapers/wallpaper_001.jpg $HOME/gitprojects/grub2-themes/background.jpg
sudo $HOME/gitprojects/grub2-themes/install.sh -s 1080p -b -t whitesur

# Section: GRUB Configuration
log "Configuring GRUB..."
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/' /etc/default/grub
sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/a GRUB_CMDLINE_LINUX="rhgb quiet mitigations=off"' /etc/default/grub
sudo update-grub
sudo update-initramfs -u -k all

# Section: Flatpak Applications Installation
log "Installing Flatpak applications..."
flatpak install $(cat $HOME/dotfiles/flatpaks_list.bak) -y

source $HOME/.bashrc

# Section: Cargo Installations
log "Installing cargo packages..."
cargo install cargo-update cargo-list kanata binsider

# Section: tgpt and Atuin Installation
log "Installing tgpt and atuin..."
curl -sSL https://raw.githubusercontent.com/aandrew-me/tgpt/main/install | bash -s /usr/local/bin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# Section: Ollama Installation
log "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# Section: Final Update and Cleanup
log "Final update and cleanup..."
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y

# Section: Source .bashrc and Restore Gnome Settings
log "Sourcing .bashrc and restoring Gnome settings..."
source $HOME/.bashrc
dconf load / <$HOME/dotfiles/gnome_settings.bak

# Section: AppArmor Enforcement
log "Enforcing AppArmor profiles..."
sudo aa-enforce /etc/apparmor.d/*

# Section: Display Completion Message and Reboot
log "Displaying completion message and rebooting..."
figlet h4ck3r m4ch1n3 | lolcat
sudo reboot
