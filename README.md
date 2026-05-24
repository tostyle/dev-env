# Coder Dev Container

Ubuntu-based development container images with Docker-in-Docker support, designed for use with [Coder](https://coder.com).



## What's Included

|              | base | node |
|--------------|:-----:|:----:|
| Docker + Compose + Buildx | x | x |
| build-essential, git (latest) | x | x |
| Python 3 + pipx | x | x |
| Systemd | x | x |
| Non-root `coder` user (UID 1000) | x | x |
| Node.js (LTS) | | x |
| Yarn | | x |

## CI/CD

GitHub Actions builds and pushes multi-architecture (`linux/amd64`, `linux/arm64`) images to **GHCR** on every push. Tagged releases (`v*`) generate versioned image tags.

---

## Nix Dev Shell + Home Manager

### 1. Edit `flake.nix` — set your machine info

```nix
mySystem = "aarch64-darwin";  # apple silicon mac
# mySystem = "x86_64-linux";  # linux / wsl
myUser   = "your-username";   # output of: whoami
```

### 2. Enter the dev shell

```bash
nix develop
```

Or with **direnv** (auto-activates on `cd`):

```bash
# one-time setup per machine
nix profile install nixpkgs#direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc  # or ~/.bashrc
source ~/.zshrc

# one-time per project
direnv allow
```

After that, just `cd` into the directory — shell is ready automatically.

---

### 3. Bootstrap (first-time setup)

Run the bootstrap script to symlink configs and apply home-manager in one step:

```bash
./bootstrap.sh
```

This will:
1. Symlink `.tmux.config` → `~/.tmux.conf`
2. Apply the home-manager configuration via `nix run nixpkgs#home-manager -- switch --flake .#coder`

> **Subsequent runs** — once `home-manager` is on your `PATH`, you can apply changes directly:
> ```bash
> home-manager switch --flake .#coder
> ```


### Install pi extension
1 npm problem need to set installed directory to ~/.local instead nix store bcz it read only dir
```
npm config set prefix ~/.local
```