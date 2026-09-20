# Updating Nix packages in this dotfiles repo

## Why this works the way it does

In this repository, package versions are **pinned by `flake.lock`**, not by whatever happens to be current in `nixpkgs` at the moment. The `home.nix` file uses packages from the `pkgs` object that comes from `flake.nix`. That `pkgs` comes from the `nixpkgs` flake input at a specific revision.

So "update my packages" really means:

1. Update the flake inputs in `flake.lock`.
2. Rebuild the Home Manager configuration so the new package versions are installed.

## Update all packages at once

```bash
cd ~/.config/coderv2/dotfiles

# Update every flake input (nixpkgs, home-manager, llm-agents, hermes-agent, ...)
nix flake update

# Apply the new versions
home-manager switch --flake .#coder
```

If `home-manager` is not yet on your PATH, use the bootstrap form instead:

```bash
nix run nixpkgs#home-manager -- switch --flake .#coder
```

## Update only the Home Manager input

If you only want to update Home Manager itself and leave everything else pinned:

```bash
cd ~/.config/coderv2/dotfiles

nix flake lock --update-input home-manager
home-manager switch --flake .#coder
```

## Update a single package source

For other inputs, use the same pattern. For example, to update only the `nixpkgs` input:

```bash
nix flake lock --update-input nixpkgs
home-manager switch --flake .#coder
```

Or to update only the AI-agent flakes:

```bash
nix flake lock --update-input llm-agents
nix flake lock --update-input hermes-agent
home-manager switch --flake .#coder
```

## Validate before applying

A quick check catches syntax errors without downloading or building anything:

```bash
nix flake check --no-build
```

Run this before `home-manager switch` whenever you edit `*.nix` files.

## Inspect what changed

After `nix flake update`, review the lockfile diff before switching:

```bash
git diff flake.lock
```

This shows which inputs were bumped and can help debug sudden build failures.

## Warning: updates can break things

`nix flake update` pulls the latest revisions of every input. A new `nixpkgs` revision can change package versions, remove deprecated options, or break compatibility with custom derivations. If something breaks after updating, you can roll back by reverting `flake.lock` and running `home-manager switch` again.

```bash
git checkout -- flake.lock
home-manager switch --flake .#coder
```

For safer updates, prefer updating one input at a time and running `nix flake check` before each switch.
