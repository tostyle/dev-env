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

### 3. Apply a home-manager profile

Profiles live in `flake.nix` under `homeConfigurations`:

| Profile | Command |
|---------|---------|
| `work` | `nix run nixpkgs#home-manager -- switch --flake .#work` |
| `personal` | `nix run nixpkgs#home-manager -- switch --flake .#personal` |

Once `home-manager` is on your `PATH` (after first switch), you can use the shorter form:

```bash
home-manager switch --flake .#work
home-manager switch --flake .#personal
```

> **First time on a new machine** always use `nix run nixpkgs#home-manager` — it bootstraps home-manager before it exists on your PATH.

### 4. Add a new profile

In `flake.nix`, add an entry inside `homeConfigurations`:

```nix
homeConfigurations = {
  work     = mkHome "work";
  personal = mkHome "personal";
  staging  = mkHome "staging";  # ← new profile
};
```

Then in `home.nix`, branch on the `profile` argument:

```nix
{ pkgs, profile, myUser, ... }:
{
  programs.git.userEmail =
    if profile == "work"     then "you@company.com"
    else if profile == "staging" then "you@staging.com"
    else "you@personal.com";
}
```

Apply it:

```bash
home-manager switch --flake .#coder
```

or

```bash
nix run nixpkgs#home-manager -- switch --flake .#coder
```
