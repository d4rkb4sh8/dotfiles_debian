#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status

log() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"
}

# Install GTFOB lookup
log "Installing GTFOB..."
pipx install git+https://github.com/nccgroup/GTFOBLookup.git

# Binsider
cargo install binsider

# Install kanata for home row mods
cargo install kanata

#Install tgpt
curl -sSL https://raw.githubusercontent.com/aandrew-me/tgpt/main/install | bash -s /usr/local/bin

# Install atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# Download the Mullvad signing key
sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc

# Add the Mullvad repository server to apt
echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$(dpkg --print-architecture)] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list

# Install the package
sudo apt update
sudo apt install mullvad-vpn

# Install ollama & install deepseek-coder-v2
curl -fsSL https://ollama.com/install.sh | sh
ollama run deepseek-coder-v2

# Final update and clean up
log "Final update and clean up..."
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y

# Source .bashrc
log "Sourcing .bashrc..."
source $HOME/.bashrc

# Display message
figlet h4ck3r m4ch1n3 | lolcat
