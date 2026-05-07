#!/bin/bash

# List of packages needed to be installed
installs=("bash-completion" "bat" "curl" "fzf" "git" "lsd" "neovim" "ripgrep" "tmux" "zoxide")

echo "Setting up environment"

dot() {
  GIT_DIR=$HOME/.dot/.git/ GIT_WORK_TREE=$HOME /usr/bin/git "$@"
}

echo "Cloning dotfiles to ${HOME}/.dot"
git clone --no-checkout git@github.com:windweaver828/dotfiles.git $HOME/.dot || {
  echo "Cloning failed..."
  exit 1
}

dot reset --hard
dot checkout -f main
dot config --local status.showUntrackedFiles no

echo "*" >$HOME/.gitignore

# Install FiraCode Fonts
if command -v fc-cache >/dev/null 2>&1; then
  if ! fc-list | grep -qi "firacode"; then
    FONT_DIR="$HOME/.local/share/fonts"
    if [ ! -d "$FONT_DIR" ]; then
      echo "Creating fonts directory at $FONT_DIR"
      mkdir -p "$FONT_DIR"
    fi
    echo "Installing FiraCode NerdFonts"
    for font in "$HOME/.dotfiles/FiraCodeNerdFont/"*.ttf; do
      cp "$font" "$FONT_DIR"
    done
    fc-cache -fv >/dev/null 2>&1
    if fc-list | grep -qi "firacode"; then
      echo "FiraCode NerdFonts installed successfully."
    else
      echo "Failed to install FiraCode NerdFonts. Please check manually."
    fi
  else
    echo "FiraCode NerdFonts are already installed."
  fi
else
  echo "fc-cache not found, you will need to install the FiraCodeNerdFont fonts manually"
fi

# Build the bat cache if possible
if command -v bat >/dev/null 2>&1; then
  bat cache --build >/dev/null 2>&1
elif command -v batcat >/dev/null 2>&1; then
  batcat cache --build >/dev/null 2>&1
fi

echo "Installation Complete"
echo

exec bash
