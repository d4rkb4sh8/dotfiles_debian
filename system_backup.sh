#!/bin/bash

# Tool name and version
TOOL_NAME="System Backup Tool"
VERSION="1.2"

# Help message
function show_help {
    echo "$TOOL_NAME v$VERSION"
    echo "Usage: $0 [OPTION]"
    echo "List, backup, or restore installed packages (apt/dnf/yum/pacman, brew, flatpak, snap, GNOME extensions, pipx, cargo, golang) and dconf settings."
    echo ""
    echo "Options:"
    echo "  -l, --list               List all installed packages and settings"
    echo "  -b, --backup FILE        Backup installed packages and settings to FILE"
    echo "  -r, --restore FILE       Restore packages and settings from FILE"
    echo "  --apt                    Include APT packages (Debian/Ubuntu)"
    echo "  --dnf                    Include DNF packages (Fedora)"
    echo "  --yum                    Include YUM packages (CentOS/RHEL)"
    echo "  --pacman                 Include Pacman packages (Arch)"
    echo "  --zypper                 Include Zypper packages (openSUSE)"
    echo "  --brew                   Include Homebrew packages"
    echo "  --flatpak                Include Flatpak packages"
    echo "  --snap                   Include Snap packages"
    echo "  --gnome-ext              Include GNOME extensions"
    echo "  --dconf                  Include GNOME dconf settings"
    echo "  --pipx                   Include Pipx packages"
    echo "  --cargo                  Include Cargo (Rust) packages"
    echo "  --golang                 Include Go packages"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --list --apt --dconf          List only APT packages and dconf settings"
    echo "  $0 --backup backup.txt           Backup all packages and settings to backup.txt"
    echo "  $0 --restore backup.txt          Restore all packages and settings from backup.txt"
    echo ""
    exit 0
}

# Default: Include all package managers and settings
INCLUDE_APT=false
INCLUDE_DNF=false
INCLUDE_YUM=false
INCLUDE_PACMAN=false
INCLUDE_ZYPPER=false
INCLUDE_BREW=true
INCLUDE_FLATPAK=true
INCLUDE_SNAP=true
INCLUDE_GNOME_EXT=true
INCLUDE_DCONF=true
INCLUDE_PIPX=true
INCLUDE_CARGO=true
INCLUDE_GOLANG=true

# Detect system package manager
function detect_package_manager {
    if command -v apt &>/dev/null; then
        INCLUDE_APT=true
    elif command -v dnf &>/dev/null; then
        INCLUDE_DNF=true
    elif command -v yum &>/dev/null; then
        INCLUDE_YUM=true
    elif command -v pacman &>/dev/null; then
        INCLUDE_PACMAN=true
    elif command -v zypper &>/dev/null; then
        INCLUDE_ZYPPER=true
    fi
}

# Parse command-line arguments
ACTION=""
BACKUP_FILE=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -l|--list) ACTION="list"; shift ;;
        -b|--backup) ACTION="backup"; BACKUP_FILE="$2"; shift 2 ;;
        -r|--restore) ACTION="restore"; BACKUP_FILE="$2"; shift 2 ;;
        --apt) INCLUDE_APT=true; shift ;;
        --dnf) INCLUDE_DNF=true; shift ;;
        --yum) INCLUDE_YUM=true; shift ;;
        --pacman) INCLUDE_PACMAN=true; shift ;;
        --zypper) INCLUDE_ZYPPER=true; shift ;;
        --brew) INCLUDE_BREW=true; shift ;;
        --flatpak) INCLUDE_FLATPAK=true; shift ;;
        --snap) INCLUDE_SNAP=true; shift ;;
        --gnome-ext) INCLUDE_GNOME_EXT=true; shift ;;
        --dconf) INCLUDE_DCONF=true; shift ;;
        --pipx) INCLUDE_PIPX=true; shift ;;
        --cargo) INCLUDE_CARGO=true; shift ;;
        --golang) INCLUDE_GOLANG=true; shift ;;
        -h|--help) show_help ;;
        *) echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

if [[ -z "$ACTION" ]]; then
    echo "No action specified. Use -h for help."
    exit 1
fi

# Detect system package manager
detect_package_manager

# List installed packages and settings
function list_packages {
    if $INCLUDE_APT; then
        echo "=== APT Packages ==="
        apt list --installed 2>/dev/null | awk -F/ '{print $1}'
        echo ""
    fi

    if $INCLUDE_DNF; then
        echo "=== DNF Packages ==="
        dnf list installed | awk '{print $1}'
        echo ""
    fi

    if $INCLUDE_YUM; then
        echo "=== YUM Packages ==="
        yum list installed | awk '{print $1}'
        echo ""
    fi

    if $INCLUDE_PACMAN; then
        echo "=== Pacman Packages ==="
        pacman -Qqe
        echo ""
    fi

    if $INCLUDE_ZYPPER; then
        echo "=== Zypper Packages ==="
        zypper packages --installed-only | awk '{print $2}'
        echo ""
    fi

    if $INCLUDE_BREW; then
        echo "=== Homebrew Packages ==="
        brew list
        echo ""
    fi

    if $INCLUDE_FLATPAK; then
        echo "=== Flatpak Packages ==="
        flatpak list --app --columns=application
        echo ""
    fi

    if $INCLUDE_SNAP; then
        echo "=== Snap Packages ==="
        snap list | awk 'NR>1 {print $1}'
        echo ""
    fi

    if $INCLUDE_GNOME_EXT; then
        echo "=== GNOME Extensions ==="
        gnome-extensions list
        echo ""
    fi

    if $INCLUDE_DCONF; then
        echo "=== GNOME dconf Settings ==="
        dconf dump / | grep -v '^\[.*\]$'
    fi

    if $INCLUDE_PIPX; then
        echo "=== Pipx Packages ==="
        pipx list --short
        echo ""
    fi

    if $INCLUDE_CARGO; then
        echo "=== Cargo (Rust) Packages ==="
        cargo install --list | grep -v '^ ' | awk '{print $1}'
        echo ""
    fi

    if $INCLUDE_GOLANG; then
        echo "=== Go Packages ==="
        go list -m all | awk '{print $1}'
        echo ""
    fi
}

# Backup installed packages and settings
function backup_packages {
    echo "Backing up packages and settings to $BACKUP_FILE..."
    {
        if $INCLUDE_APT; then
            echo "=== APT Packages ==="
            apt list --installed 2>/dev/null | awk -F/ '{print $1}'
            echo ""
        fi

        if $INCLUDE_DNF; then
            echo "=== DNF Packages ==="
            dnf list installed | awk '{print $1}'
            echo ""
        fi

        if $INCLUDE_YUM; then
            echo "=== YUM Packages ==="
            yum list installed | awk '{print $1}'
            echo ""
        fi

        if $INCLUDE_PACMAN; then
            echo "=== Pacman Packages ==="
            pacman -Qqe
            echo ""
        fi

        if $INCLUDE_ZYPPER; then
            echo "=== Zypper Packages ==="
            zypper packages --installed-only | awk '{print $2}'
            echo ""
        fi

        if $INCLUDE_BREW; then
            echo "=== Homebrew Packages ==="
            brew list
            echo ""
        fi

        if $INCLUDE_FLATPAK; then
            echo "=== Flatpak Packages ==="
            flatpak list --app --columns=application
            echo ""
        fi

        if $INCLUDE_SNAP; then
            echo "=== Snap Packages ==="
            snap list | awk 'NR>1 {print $1}'
            echo ""
        fi

        if $INCLUDE_GNOME_EXT; then
            echo "=== GNOME Extensions ==="
            gnome-extensions list
            echo ""
        fi

        if $INCLUDE_DCONF; then
            echo "=== GNOME dconf Settings ==="
            dconf dump /
        fi

        if $INCLUDE_PIPX; then
            echo "=== Pipx Packages ==="
            pipx list --short
            echo ""
        fi

        if $INCLUDE_CARGO; then
            echo "=== Cargo (Rust) Packages ==="
            cargo install --list | grep -v '^ ' | awk '{print $1}'
            echo ""
        fi

        if $INCLUDE_GOLANG; then
            echo "=== Go Packages ==="
            go list -m all | awk '{print $1}'
            echo ""
        fi
    } > "$BACKUP_FILE"
    echo "Backup complete."
}

# Restore packages and settings
function restore_packages {
    if [[ ! -f "$BACKUP_FILE" ]]; then
        echo "Backup file not found: $BACKUP_FILE"
        exit 1
    fi

    echo "Restoring packages and settings from $BACKUP_FILE..."

    if $INCLUDE_APT && grep -q "=== APT Packages ===" "$BACKUP_FILE"; then
        echo "Restoring APT packages..."
        grep -A 1000 "=== APT Packages ===" "$BACKUP_FILE" | grep -v "=== APT Packages ===" | xargs sudo apt install -y
    fi

    if $INCLUDE_DNF && grep -q "=== DNF Packages ===" "$BACKUP_FILE"; then
        echo "Restoring DNF packages..."
        grep -A 1000 "=== DNF Packages ===" "$BACKUP_FILE" | grep -v "=== DNF Packages ===" | xargs sudo dnf install -y
    fi

    if $INCLUDE_YUM && grep -q "=== YUM Packages ===" "$BACKUP_FILE"; then
        echo "Restoring YUM packages..."
        grep -A 1000 "=== YUM Packages ===" "$BACKUP_FILE" | grep -v "=== YUM Packages ===" | xargs sudo yum install -y
    fi

    if $INCLUDE_PACMAN && grep -q "=== Pacman Packages ===" "$BACKUP_FILE"; then
        echo "Restoring Pacman packages..."
        grep -A 1000 "=== Pacman Packages ===" "$BACKUP_FILE" | grep -v "=== Pacman Packages ===" | xargs sudo pacman -S --noconfirm
    fi

    if $INCLUDE_ZYPPER && grep -q "=== Zypper Packages ===" "$BACKUP_FILE"; then
        echo "Restoring Zypper packages..."
        grep -A 1000 "=== Zypper Packages ===" "$BACKUP_FILE" | grep -v "=== Zypper Packages ===" | xargs sudo zypper install -y
    fi

    if $INCLUDE_BREW && grep -q "=== Homebrew Packages ===" "$BACKUP_FILE"; then
        echo "Restoring Homebrew packages..."
        grep -A 1000 "=== Homebrew Packages ===" "$BACKUP_FILE" | grep -v "=== Homebrew Packages ===" | xargs brew install
    fi

    if $INCLUDE_FLATPAK && grep -q "=== Flatpak Packages ===" "$BACKUP_FILE"; then
        echo "Restoring Flatpak packages..."
        grep -A 1000 "=== Flatpak Packages ===" "$BACKUP_FILE" | grep -v "=== Flatpak Packages ===" | xargs flatpak install -y
    fi

    if $INCLUDE_SNAP && grep -q "=== Snap Packages ===" "$BACKUP_FILE"; then
        echo "Restoring Snap packages..."
        grep -A 1000 "=== Snap Packages ===" "$BACKUP_FILE" | grep -v "=== Snap Packages ===" | xargs sudo snap install
    fi

    if $INCLUDE_GNOME_EXT && grep -q "=== GNOME Extensions ===" "$BACKUP_FILE"; then
        echo "Restoring GNOME extensions..."
        grep -A 1000 "=== GNOME Extensions ===" "$BACKUP_FILE" | grep -v "=== GNOME Extensions ===" | xargs -I {} gnome-extensions enable {}
    fi

    if $INCLUDE_DCONF && grep -q "=== GNOME dconf Settings ===" "$BACKUP_FILE"; then
        echo "Restoring GNOME dconf settings..."
        dconf load / < <(grep -A 1000 "=== GNOME dconf Settings ===" "$BACKUP_FILE" | grep -v "=== GNOME dconf Settings ===")
    fi

    if $INCLUDE_PIPX && grep -q "=== Pipx Packages ===" "$BACKUP_FILE"; then
        echo "Restoring Pipx packages..."
        grep -A 1000 "=== Pipx Packages ===" "$BACKUP_FILE" | grep -v "=== Pipx Packages ===" | xargs pipx install
    fi

    if $INCLUDE_CARGO && grep -q "=== Cargo (Rust) Packages ===" "$BACKUP_FILE"; then
        echo "Restoring Cargo packages..."
        grep -A 1000 "=== Cargo (Rust) Packages ===" "$BACKUP_FILE" | grep -v "=== Cargo (Rust) Packages ===" | xargs cargo install
    fi

    if $INCLUDE_GOLANG && grep -q "=== Go Packages ===" "$BACKUP_FILE"; then
        echo "Restoring Go packages..."
        grep -A 1000 "=== Go Packages ===" "$BACKUP_FILE" | grep -v "=== Go Packages ===" | xargs go install
    fi

    echo "Restoration complete."
}

# Execute the action
case "$ACTION" in
    list) list_packages ;;
    backup) backup_packages ;;
    restore) restore_packages ;;
    *) echo "Invalid action"; exit 1 ;;
esac
