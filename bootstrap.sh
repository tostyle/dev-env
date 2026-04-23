#!/usr/bin/env bash
set -euo pipefail

echo "==> Linking tmux config..."
ln -sf "$(pwd)/.tmux.config" "$HOME/.tmux.conf"

echo "==> Applying home-manager configuration..."
nix run nixpkgs#home-manager -- switch --flake .#coder

echo "==> Done."
