#!/usr/bin/env bash

# Define the path to your dotfiles directory
DOTFILES_DIR="$HOME/dotfiles"

# Function to remove existing files and replace them with symlinks
replace_with_symlinks() {
  local target=$1
  if [ -e "$target" ]; then
    rm -rf "$target"
  fi
  ln -s "${DOTFILES_DIR}/${target}" "$target"
}

# Export the function so that it can be used by GNU Stow
export -f replace_with_symlinks
export DOTFILES_DIR

# Run GNU Stow to manage symbolic links
stow --ignore=\.git --ignore=README.md --ignore=LICENSE --ignore=.DS_Store --target=/home/h4ck3r $(basename $DOTFILES_DIR)

# Iterate over all files in the dotfiles directory and replace them if they exist
for file in "${DOTFILES_DIR}/"*; do
  target=$(echo "$file" | sed "s|^${DOTFILES_DIR}/||")
  if [ -e "$HOME/$target" ]; then
    replace_with_symlinks "SHOME/$target"
  fi
done
