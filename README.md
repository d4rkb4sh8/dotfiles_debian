# Debian Bootstrap and Backup Scripts

These scripts automate the setup and restoration of a customized Debian system, ensuring a reproducible environment across installations. They handle package management, configurations, theming, security, and more.

## Features

- **System Setup**: Installs essential tools (Git, curl, etc.), removes bloatware, and configures repositories.
- **Dotfiles Management**: Clones and symlinks dotfiles using `stow`.
- **Package Installation**: Installs APT, Flatpak, Snap, Homebrew, and Cargo packages from predefined lists.
- **Customization**: Applies themes (GRUB, icons), shell enhancements (`ble.sh`, Starship), and fonts.
- **Security**: Configures UFW firewall, AppArmor profiles, and kernel mitigations.
- **Backup & Restore**: Captures installed packages and GNOME settings for future replication.

---

## `bootstrap.sh` Overview

Automates the entire system setup process. Key sections:

```bash
# Initial Setup
sudo apt install -y git gh curl gawk cmake
sudo sed -i '/^deb / s/$/ contrib non-free/' /etc/apt/sources.list

# Remove Bloatware
sudo apt purge -y audacity gimp gnome-games libreoffice*

# Dotfiles and Git Projects
git clone https://github.com/d4rkb4sh8/dotfiles.git $HOME/dotfiles
stow --adopt . && git restore .

# Package Installation (APT, Flatpak, Snap, Homebrew)
sudo apt install $(cat $HOME/dotfiles/backups/apt_list.bak)
flatpak install $(cat $HOME/dotfiles/backups/flatpaks_list.bak)
brew install $(cat $HOME/dotfiles/backups/brew_list.bak)

# Shell Customization
echo 'source ~/.local/share/blesh/ble.sh' >>~/.bashrc
curl -sS https://starship.rs/install.sh | sh

# Security and Kernel
sudo ufw enable
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/' /etc/default/grub

# Final Steps
dconf load / <$HOME/dotfiles/backups/gnome_settings.bak
sudo reboot
```

---

## `settings_backup.sh` Overview

Captures current system settings and installed packages for reproducibility:

```bash
# Backups include:
dconf dump / > gnome_settings.bak          # GNOME configurations
apt list --installed > apt_list.bak        # APT packages
flatpak list --app > flatpaks_list.bak     # Flatpak apps
brew list -1 > brew_list.bak               # Homebrew packages
snap list > snap_list.bak                  # Snap packages
```

---

## Reproducibility Workflow

1. **Backup**: Run `settings_backup.sh` to save the current system state to `dotfiles/backups/`.
2. **Version Control**: Commit the updated backups to your dotfiles repository.
3. **Restore**: On a fresh Debian install, run `bootstrap.sh` to:
   - Install all packages from the backups.
   - Apply configurations, themes, and security settings.
   - Replicate the original environment.

> **Note**: Ensure the `dotfiles` repo contains the required backup files (`apt_list.bak`, `gnome_settings.bak`, etc.). Some commands may require `sudo` privileges.
