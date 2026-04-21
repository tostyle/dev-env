# Dev Environment — Nix + Dev Container

A fully reproducible development environment powered by **Nix** and **VS Code Dev Containers**.

## What's included

| Tool | Purpose |
|------|---------|
| `git` | Version control |
| `podman` | Rootless Docker-compatible container runtime |
| `nvm` | Node Version Manager |
| `node` (LTS) | JavaScript runtime — installed via nvm |
| `bun` | Fast JS runtime & package manager |
| `pnpm` | Efficient Node package manager |

---

## Project structure

```
.
├── flake.nix                    # Nix: declares all packages & the dev shell
├── flake.lock                   # Nix: auto-generated lockfile (commit this)
└── .devcontainer/
    ├── devcontainer.json        # Dev Container: container config
    └── setup.sh                 # Dev Container: one-time post-create script
```

---

## Getting started

### Option A — VS Code Dev Container (recommended)

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) or [Podman Desktop](https://podman-desktop.io/)
2. Install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) VS Code extension
3. Open this folder in VS Code
4. Click **Reopen in Container** when prompted (or run `Dev Containers: Reopen in Container` from the command palette)

VS Code will build the container, install Nix, and run `setup.sh` automatically. When it's done, open a terminal and run:

```bash
nix develop
```

### Option B — Local Nix (without Docker)

If you have Nix installed on your host machine:

```bash
# Install Nix (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh

# Enter the dev shell
nix develop
```

---

## Daily workflow

```bash
# Enter the dev shell — all tools become available in your PATH
nix develop

# Switch Node version
nvm install 22
nvm use 22

# Run commands in the dev shell without entering it interactively
nix develop --command bash -c "node --version"
```

Once inside `nix develop`, all tools (`git`, `podman`, `bun`, `pnpm`, `nvm`) are available.

---

## Core concepts

### What `nix develop` does

`nix develop` opens the development shell defined by this project's `flake.nix`.

For this repo, the command does the following:

1. Reads `flake.nix` and `flake.lock`
2. Resolves the exact pinned `nixpkgs` revision from `flake.lock`
3. Downloads or builds the packages listed in `devShells.default`
4. Starts a shell with those packages added to your `PATH`
5. Runs the `shellHook` from `flake.nix`

In this project, that means after `nix develop` you get:

- `git`
- `podman`
- `nvm`
- `bun`
- `pnpm`

And the `shellHook` also prepares `nvm` by:

- setting `NVM_DIR`
- creating the `nvm.sh` symlink in `$HOME/.nvm`
- sourcing `nvm.sh` so the `nvm` command is available in the current shell

Important: `nix develop` does not install packages globally like `apt` or `brew`. It creates a reproducible shell session based on the project definition. When you exit the shell, your global environment is unchanged.

### What a Nix flake is

A Nix flake is the project-level definition that tells Nix how to build a reproducible environment.

In practice, a flake is usually made of two files:

- `flake.nix` — the recipe
- `flake.lock` — the exact pinned versions of that recipe's inputs

You can think of them like this:

- `flake.nix` = what the project wants
- `flake.lock` = the exact versions used
- `nix develop` = enter the environment produced from those files

In this repo, `flake.nix` defines one main output: `devShells.default`. That is the shell you enter when you run `nix develop`.

### How `flake.nix` and `nix develop` work together

The relationship is:

```text
flake.nix      -> declares the dev shell
flake.lock     -> pins exact dependency versions
nix develop    -> enters that pinned dev shell
shellHook      -> runs extra shell setup after the shell starts
```

So in this repo:

- `flake.nix` says which tools should exist
- `flake.lock` ensures everyone gets the same versions
- `nix develop` gives you those tools in a shell
- `shellHook` makes `nvm` usable immediately

### Useful flake commands

```bash
# Show what this flake exports
nix flake show

# Enter the development shell
nix develop

# Update all pinned inputs in flake.lock
nix flake update

# Update only nixpkgs
nix flake update nixpkgs
```

---

## How it works

### How Dev Containers work

```
VS Code  →  reads .devcontainer/devcontainer.json
         →  pulls base Ubuntu 24.04 image
         →  runs Nix feature installer  →  Nix is now inside the container
         →  starts the container and mounts your workspace
         →  runs setup.sh once  →  Node LTS is installed via nvm
         →  attaches VS Code to the container
```

The key settings in `devcontainer.json`:

| Field | What it does |
|-------|-------------|
| `image` | Base OS image (Ubuntu 24.04) |
| `features` | Auto-installs Nix with flakes enabled |
| `runArgs: ["--privileged"]` | Required for podman to run containers inside the container |
| `postCreateCommand` | Runs `setup.sh` once after the container is created |
| `remoteUser` | Your user inside the container (`vscode`) |

### How Nix works

Nix is a **purely functional package manager**. Every package is stored as an immutable path in `/nix/store/`:

```
/nix/store/abc123...-git-2.44.0/bin/git
/nix/store/xyz789...-nvm-0.39.7/nvm.sh
```

The hash in the path is derived from every input (source code, compiler version, flags). This means:
- Two versions of the same package coexist without conflicts
- Builds are 100% reproducible — the same hash always gives the same binary
- Rolling back is trivial — just switch which store path is on your `PATH`

### How `flake.nix` works

A Nix **Flake** is the modern way to declare reproducible environments.

```
flake.nix
├── inputs   →  where to fetch packages from
│               nixpkgs = the Nix package repository (80,000+ packages)
│               flake-utils = helper for multi-platform support
└── outputs  →  what to produce
                devShells.default = the shell you get from `nix develop`
```

When you run `nix develop`, Nix:
1. Reads `flake.lock` to get exact commit hashes for `nixpkgs`
2. Builds or downloads every package listed in `packages`
3. Creates a temporary shell with those packages on `PATH`
4. Runs `shellHook` — where we set up `NVM_DIR` and activate nvm

### Adding a new package

1. Find the package name on [search.nixos.org](https://search.nixos.org/packages)
2. Add it to the `packages` list in `flake.nix`:

```nix
packages = with pkgs; [
  git
  podman
  nvm
  bun
  pnpm
  ripgrep   # ← new package
];
```

3. Re-enter the dev shell:

```bash
nix develop
```

That's it — no `apt install`, no `brew install`, no version conflicts.

### How nvm integrates with Nix

`nvm` is unusual because it's a **shell function** (sourced, not a binary), so it can't just live in `PATH`. The setup works in three steps:

1. **`flake.nix`** puts `nvm` in `packages` → its `nvm.sh` ends up in the Nix store
2. **`shellHook`** symlinks the Nix-store `nvm.sh` → `$HOME/.nvm/nvm.sh` and sources it
3. **`setup.sh`** runs `nvm install --lts` inside the dev shell to install Node
4. **`.bashrc`** gets the standard nvm init lines → nvm works in every future shell session without needing to run `nix develop` first

### The `flake.lock` file

`flake.lock` pins the exact git commit of `nixpkgs` used. Commit it to git so every developer gets the **exact same package versions**.

```bash
# Update all inputs to their latest commits
nix flake update

# Update only nixpkgs
nix flake update nixpkgs
```
