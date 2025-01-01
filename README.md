The repository contains a collection of dot files used by the author to manage their Linux environment. The repository uses GNU Stow to manage the
installation and configuration of these dot files.

## Directory Structure

- `.bootstrap.sh`: A script used to install required packages for the dot files.
- `dotfiles`: This directory contains all the dot files managed by Stow.
  - `alias`: Alias definitions for frequently used commands.
  - `bashrc`: Bash shell configuration file.
  - `gitconfig`: Git configuration file.
  - `hostname`: Hostname and IP address management script.
  - `keybindings`: Keybinding definitions for Vim.
  - `vimrc`: Vim configuration file.

## Package Installation

The `.bootstrap.sh` script is used to install required packages for the dot files. The package names and their dependencies are specified in this script.

## Stow Configuration

Stow, a package manager for managing binary directories, is used to manage the installation of the dot files. The `stow.conf` file contains configuration options for Stow.

Here's an example README.md file that can be generated based on this information:

**d4rkb4sh8/dotfiles**

A collection of dot files used to manage the Linux environment.

## **Directory Structure**

- `.bootstrap.sh`: Script used to install required packages.
- `dotfiles`: Directory containing all managed dot files.
  - `alias`: Alias definitions.
  - `bashrc`: Bash shell configuration file.
  - `gitconfig`: Git configuration file.
  - `hostname`: Hostname and IP address management script.
  - `keybindings`: Keybinding definitions for Vim.
  - `vimrc`: Vim configuration file.

## **Package Installation**

The `.bootstrap.sh` script is used to install required packages. Package names and their dependencies are specified in this script.

## **Stow Configuration**

Stow, a package manager for managing binary directories, is used to manage the installation of dot files. The `stow.conf` file contains configuration options for Stow.

## **Usage**

1. Clone the repository: `git clone https://github.com/d4rkb4sh8/dotfiles.git`
2. Run `.bootstrap.sh` to install required packages.
3. Use Stow to manage installation and configuration of dot files.

## **License**

This project is licensed under [LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html).
