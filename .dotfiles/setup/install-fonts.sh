#!/usr/bin/env bash
set -Eeuo pipefail

FONT_SRC="${FONT_SRC:-$HOME/.dotfiles/FiraCodeNerdFont}"
FONT_DIR="${FONT_DIR:-$HOME/.local/share/fonts}"

echo "Installing fonts"
echo

if ! command -v fc-cache >/dev/null 2>&1; then
  echo "fc-cache not found."
  echo "Install fontconfig or install fonts manually."
  exit 1
fi

if [ ! -d "$FONT_SRC" ]; then
  echo "Font source directory not found:"
  echo "  $FONT_SRC"
  exit 1
fi

shopt -s nullglob
fonts=("$FONT_SRC"/*.ttf "$FONT_SRC"/*.otf)
shopt -u nullglob

if [ "${#fonts[@]}" -eq 0 ]; then
  echo "No .ttf or .otf font files found in:"
  echo "  $FONT_SRC"
  exit 1
fi

mkdir -p "$FONT_DIR"

for font in "${fonts[@]}"; do
  cp -f "$font" "$FONT_DIR/"
done

fc-cache -fv "$FONT_DIR" >/dev/null 2>&1

echo "Fonts installed to:"
echo "  $FONT_DIR"
