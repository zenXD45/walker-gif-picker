#!/usr/bin/env bash

set -e

echo "==> Starting Walky Gifs Installer..."

echo "==> 📦 Checking and installing system dependencies..."

if command -v pacman &> /dev/null; then
    sudo pacman -S --needed --noconfirm wl-clipboard python python-requests python-pillow jq curl libnotify
elif command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y wl-clipboard python3 python3-requests python3-pil jq curl libnotify-bin
elif command -v dnf &> /dev/null; then
    sudo dnf install -y wl-clipboard python3 python3-requests python3-pillow jq curl libnotify
else
    echo "⚠️  Unsupported package manager. Please manually install: wl-clipboard, python3, requests, Pillow, jq, curl, notify-send."
fi

echo "==> 📂 Copying files to their respective locations..."

# 1. Provide the Walker Search Backend
echo "  -> Setting up Walker Search Backend..."
mkdir -p "$HOME/.config/walker/scripts/"
cp scripts/gif_search.sh "$HOME/.config/walker/scripts/"
chmod +x "$HOME/.config/walker/scripts/gif_search.sh"

# 2. Provide the Elephant UI Menu
echo "  -> Setting up Elephant UI Menu..."
mkdir -p "$HOME/.config/elephant/menus/"
cp menus/gifs.lua "$HOME/.config/elephant/menus/"

# 3. Provide the Clipboard Python Handler
echo "  -> Setting up Clipboard Handler (requires sudo)..."
sudo cp bin/gif-copy /usr/local/bin/gif-copy
sudo chmod +x /usr/local/bin/gif-copy

echo ""
echo "==> ✅ Installation Complete!"
echo "--------------------------------------------------------"
echo "Please ensure you perform the following manual steps:"
echo "1. Run 'nano ~/.config/walker/scripts/gif_search.sh' and add your Klipy API Key."
echo "2. Edit '~/.config/walker/config.toml' and add:"
echo "   [[providers.prefixes]]"
echo "   prefix = \"gif\""
echo "   provider = \"menus:gifs\""
echo "3. Run 'pkill elephant; sleep 1; elephant &' and 'pkill walker; sleep 1; walker --gapplication-service &'"
echo "--------------------------------------------------------"
