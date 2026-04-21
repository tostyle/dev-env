#!/usr/bin/env bash
# ============================================================
# .devcontainer/setup.sh
# Runs once after the container is created (postCreateCommand).
# ============================================================
set -euo pipefail

echo "=== Initializing Nix development environment ==="
echo ""

# ── Step 1: Install Node.js LTS via nvm ─────────────────────────────────────
# We can't just run `nvm install` in a plain shell because nvm is a shell
# function, not a binary.  `nix develop --command` runs our command *inside*
# the Nix dev shell defined in flake.nix, where the shellHook has already:
#   • exported NVM_DIR
#   • symlinked nvm.sh into $NVM_DIR
#   • sourced nvm.sh  →  so the `nvm` function is available
echo "[1/2] Installing Node.js LTS via nvm (inside nix dev shell)..."

nix develop --command bash -c '
  nvm install --lts
  nvm use --lts
  nvm alias default lts/*
  echo "  ✓ Node.js $(node --version)"
  echo "  ✓ npm $(npm --version)"
'

# ── Step 2: Persist nvm init in .bashrc ─────────────────────────────────────
# After the first `nix develop` run, $NVM_DIR/nvm.sh is a symlink pointing to
# the Nix-store path of nvm.  The standard two-liner below will load nvm on
# every new shell session — no need to run `nix develop` just to use node.
echo "[2/2] Configuring shell (~/.bashrc)..."

BASHRC="$HOME/.bashrc"

if ! grep -q "NVM_DIR" "$BASHRC"; then
  cat >> "$BASHRC" << 'EOF'

# ── nvm (Node Version Manager) — symlink managed by Nix ───────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"               # loads nvm
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
EOF
fi

echo ""
echo "=== Setup complete ==="
echo ""
echo "Available tools (after running 'nix develop'):"
echo "  git     — $(git --version 2>/dev/null | head -1 || echo 'via nix')"
echo "  bun     — bun $(bun --version 2>/dev/null || echo 'via nix')"
echo "  pnpm    — pnpm $(pnpm --version 2>/dev/null || echo 'via nix')"
echo "  node    — available; reload shell or run: nvm use --lts"
echo ""
echo "  → Run 'nix develop' to enter the full environment."
