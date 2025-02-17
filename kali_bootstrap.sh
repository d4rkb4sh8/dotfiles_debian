#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status

log() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"
}

# Edit /etc/default/grub for GRUB settings
log "Configuring GRUB settings..."
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/' /etc/default/grub
sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/a GRUB_CMDLINE_LINUX="rhgb quiet mitigations=off"' /etc/default/grub

# Update GRUB and initramfs
log "Updating GRUB and initramfs..."
sudo update-grub
sudo update-initramfs -u -k all

# Remove bloatware and clean up
log "Removing bloatware and cleaning up..."
sudo apt purge -y audacity gimp gnome-games libreoffice* && sudo apt autoremove -y && sudo apt autoclean -y

# Define APT packages
APT_PACKAGES=(
  apparmor-profiles apparmor-utils joplin gcc asciiart autoconf bat bison btop
  build-essential cmake cpufetch curl dconf-cli dict neovim gnome-software-plugin-flatpak
  flatpak gpg gpgv2 gtk2-engines-murrine httpie info ncal nala pipx openssl
  gnome-shell-extension-manager gpaste-2 linux-headers$(uname -r) lm-sensors mitmproxy speedtest-cli
  clamav dkms fd-find ffmpeg figlet file fastfetch eza font-manager fzf gawk gdebi gh git
  sd rsync gpg httpie imagemagick info lolcat lynis mitmproxy most nala ncal npm openssl pass
  gitleaks gnome-clocks gnome-weather patchelf plocate postgresql postgresql-contrib
  procps python-is-python3 stow terminator rkhunter tldr ufw thefuck vlc w3m wget wikipedia2text xh yt-dlp zathura
)

# Update, upgrade and install APT packages in a single step
log "Updating, upgrading, and installing packages..."
sudo apt update -y && sudo apt full-upgrade -y && sudo apt install -y "${APT_PACKAGES[@]}" && sudo apt autoremove -y && sudo apt autoclean -y

# Install latest flathub & flatpak

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install ble.sh
cd $HOME
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
echo 'source ~/.local/share/blesh/ble.sh' >>~/.bashrc

# Install Hack Nerd Font
log "Installing Hack Nerd Font..."
mkdir -p ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip -O /tmp/Hack.zip
unzip /tmp/Hack.zip -d ~/.local/share/fonts
fc-cache -fv

# Set up UFW (Uncomplicated Firewall)
log "Setting up UFW..."
sudo ufw limit 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# Install rust
log "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# setup gitprojects
log "setting up gitprojects..."
mkdir $HOME/gitprojects
cd $HOME/gitprojects
git clone https://github.com/d4rkb4sh8/main.git
git clone https://github.com/d4rkb4sh8/notes.git
#git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

## install dotfiles and stow them.
cd $HOME
git clone https://github.com/d4rkb4sh8/dotfiles.git
cd dotfiles
stow --adopt .
git restore .

#Install flatpaks
flatpak install $(cat $HOME/dotfiles/flatpaks_list.bak)

# add wallpapers
log "adding wallpapers..."
cp -r $HOME/gitprojects/main/wallpapers $HOME/Pictures

# setup GRC colors
log "setting up GRC colors..."
cd $HOME/gitprojects
git clone https://github.com/garabik/grc.git
cd $HOME/gitprojects/grc
sudo ./install.sh
sudo cp /etc/profile.d/grc.sh /etc
echo "# colorize output
GRC_ALIASES=true
[[ -s "/etc/profile.d/grc.sh" ]] && source /etc/grc.sh" >>$HOME/.bashrc

# alfa wireless adapter realtek
cd $HOME/gitprojects/
git clone https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au
sudo make dkms_install

# Install Tela-circle-icons
log "Installing Tela-circle-icons..."
cd $HOME/Downloads
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
cd Tela-circle-icon-theme
./install.sh

# setup Starship prompt
log "setting up Starship..."
curl -sS https://starship.rs/install.sh | sh
starship preset nerd-font-symbols -o ~/.config/starship.toml

# Install Grub2 custom theme
log "Installing Grub theme..."
cd $HOME/gitprojects
git clone https://github.com/vinceliuice/grub2-themes.git
cd $HOME/gitprojects/grub2-themes
cp $HOME/Pictures/wallpapers/wallpaper_001.jpg $HOME/gitprojects/grub2-themes/background.jpg
sudo ./install.sh -s 1080p -b -t whitesur

source $HOME/.bashrc

# Install GTFOB lookup
log "Installing GTFOB..."
pipx install git+https://github.com/nccgroup/GTFOBLookup.git

# Binsider
cargo install binsider
cargo install cargo-update
cargo install cargo-list

# Install kanata for home row mods
cargo install kanata

#Install tgpt
curl -sSL https://raw.githubusercontent.com/aandrew-me/tgpt/main/install | bash -s /usr/local/bin

# Install atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Final update and clean up
log "Final update and clean up..."
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y

# Gnome restore
dconf load / <$HOME/dotfiles/gnome_backup.bak

# Apparmor
sudo aa-enforce /etc/apparmor.d/*

# Source .bashrc
log "Sourcing .bashrc..."
source $HOME/.bashrc

# Display message
figlet h4ck3r m4ch1n3 | lolcat

sudo reboot
