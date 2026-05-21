#!/usr/bin/env bash
set -euo pipefail

# ── tmux config (skip if .tmux.config not in repo yet) ───────────────────────
# if [[ -f "$(pwd)/.tmux.config" ]]; then
#   echo "==> Linking tmux config..."
#   ln -sf "$(pwd)/.tmux.config" "$HOME/.tmux.conf"
#   command -v tmux &>/dev/null && tmux source-file ~/.tmux.conf || true
# fi

echo "==> Applying home-manager configuration..."
nix run nixpkgs#home-manager -- switch --flake .#coder
echo "==> Done."
