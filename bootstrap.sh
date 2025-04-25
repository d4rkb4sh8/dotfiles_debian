#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
#set -e

# Initialize tracking arrays
failed_apt=()
failed_flatpak=()
failed_snap=()
failed_brew=()
excluded_apt_packages=()

# Function to log messages with a timestamp
log() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"
}

# Section: Initial Setup
log "Starting initial setup..."
sudo sed -i '/^deb / s/$/ contrib non-free/' /etc/apt/sources.list
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y stow git gh curl gawk cmake linux-headers-$(uname -r)

# Section: Remove Bloatware
log "Removing bloatware..."
sudo apt purge -y audacity gimp gnome-games libreoffice*

# Section: Git Projects and Dotfiles Setup
log "Setting up gitprojects and dotfiles..."
mkdir -p "$HOME/gitprojects"
rm -rf "$HOME/.bashrc"
git clone https://github.com/d4rkb4sh8/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles" && stow --adopt . && git restore .

# Remove specified packages from apt_list.bak
log "Filtering APT package list..."
file="$HOME/dotfiles/backups/apt_list.bak"

# Check if the file exists
if [[ ! -f "$file" ]]; then
  echo "Error: $file not found." >&2
  exit 1
fi

# Define the packages to remove (with regex patterns)
packages=(
  balena-etcher
  mullvad-vpn
  net\.downloadhelper\.coapp # Escape dots for literal matching
  popcorn-time
  ulauncher
  'virtualbox-*.*' # Match any VirtualBox version using regex wildcard
)

# Join packages into a regex pattern
pattern=$(
  IFS="|"
  echo "^(${packages[*]})$"
)

# Remove lines and overwrite the original file
grep -Ev "$pattern" "$file" >"$file.tmp" && mv "$file.tmp" "$file"

echo "Removed specified packages from $file successfully."

# Section: Install APT Packages
log "Installing APT packages..."
sudo apt install -y $(cat "$HOME/dotfiles/backups/apt_list.bak")

# Check for failed APT packages
while read -r pkg; do
  if ! dpkg -l | grep -q "^ii  $pkg "; then
    failed_apt+=("$pkg")
  fi
done <"$apt_list"

# Section: Flatpak and Snap Setup
log "Setting up Flatpak and Snap..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y $(cat "$HOME/dotfiles/backups/flatpaks_list.bak")

# Check for failed Flatpak packages
while read -r pkg; do
  if ! flatpak list | grep -qi "$pkg"; then
    failed_flatpak+=("$pkg")
  fi
done <"$HOME/dotfiles/backups/flatpaks_list.bak"

sudo snap install snapd snap-store
snap install $(cat "$HOME/dotfiles/backups/snap_list.bak")

# Check for failed Snap packages
while read -r pkg; do
  if ! snap list | grep -q "^$pkg "; then
    failed_snap+=("$pkg")
  fi
done <"$HOME/dotfiles/backups/snap_list.bak"

# Section: ble.sh Installation
log "Installing ble.sh..."
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git "$HOME/ble.sh"
make -C "$HOME/ble.sh" install PREFIX=~/.local
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
ulimit -n 8192
brew install gcc $(cat "$HOME/dotfiles/backups/brew_list.bak")

# Check for failed Homebrew packages
while read -r pkg; do
  if ! brew list | grep -q "^$pkg$"; then
    failed_brew+=("$pkg")
  fi
done <"$HOME/dotfiles/backups/brew_list.bak"

# Section: Icon Theme Installation
log "Installing Tela-circle-icons..."
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git "$HOME/Downloads/Tela-circle-icon-theme"
"$HOME/Downloads/Tela-circle-icon-theme/install.sh"

# Section: GRUB Custom Theme Installation
log "Installing Grub theme..."
git clone https://github.com/vinceliuice/grub2-themes.git "$HOME/gitprojects/grub2-themes"
cp "$HOME/Pictures/wallpapers/wallpaper_001.jpg" "$HOME/gitprojects/grub2-themes/background.jpg"
sudo "$HOME/gitprojects/grub2-themes/install.sh" -s 1080p -b -t whitesur

# Section: GRUB Configuration
log "Configuring GRUB..."
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/' /etc/default/grub
sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/a GRUB_CMDLINE_LINUX="rhgb quiet mitigations=off"' /etc/default/grub
sudo update-grub
sudo update-initramfs -u -k all

# Section: AppArmor Enforcement
log "Enforcing AppArmor profiles..."
sudo aa-enforce /etc/apparmor.d/*

# Section: Source .bashrc and Restore Gnome Settings
log "Sourcing .bashrc and restoring Gnome settings..."
source "$HOME/.bashrc"
dconf load / <"$HOME/dotfiles/backups/gnome_settings.bak"

# Section: Installation Summary
log "Installation Summary:"

print_failed() {
  local category=$1
  shift
  local packages=("$@")

  if [ ${#packages[@]} -gt 0 ]; then
    log "Failed $category packages:"
    printf ' - %s\n' "${packages[@]}"
    echo ""
  fi
}

print_failed "APT" "${failed_apt[@]}"
print_failed "Flatpak" "${failed_flatpak[@]}"
print_failed "Snap" "${failed_snap[@]}"
print_failed "Homebrew" "${failed_brew[@]}"

if [ ${#excluded_apt_packages[@]} -gt 0 ]; then
  log "The following packages were excluded and require manual installation:"
  printf ' - %s\n' "${excluded_apt_packages[@]}"
  echo "Install them manually with: sudo apt install <package>"
  echo ""
fi

# Section: Display Completion Message and Reboot
log "Displaying completion message and rebooting..."
if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
  figlet h4ck3r m4ch1n3 | lolcat
fi

#sudo reboot
