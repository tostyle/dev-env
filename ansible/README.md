# Ansible — dotfiles bootstrap

## Structure

```
ansible/
  site.yml             # master playbook — runs everything
  ssh-keys.yml         # generates ~/.ssh/id_coder key
  install-packages.yml # installs system packages on non-Nix machines
```

**Pattern:** one playbook per concern, `site.yml` glues them together. Add more playbooks (e.g. `dotfiles.yml`, `git.yml`) and import them in `site.yml`.

---

## Prerequisites

```sh
# Debian/Ubuntu
sudo apt install ansible

# macOS
brew install ansible

# Nix (already in home.packages if you ran home-manager switch)
nix run nixpkgs#ansible -- --version
```

---

## Running

### Full bootstrap (SSH keys + packages)
```sh
cd ~/dotfiles
ansible-playbook ansible/site.yml
```
> `install-packages.yml` uses `become: true` (sudo). You will be prompted for your password unless passwordless sudo is configured.

### SSH keys only (no sudo required)
```sh
ansible-playbook ansible/ssh-keys.yml
```
Generates `~/.ssh/id_coder` (ed25519). Prints the public key at the end — add it to GitHub/GitLab/`authorized_keys` as needed. Skips generation if the key already exists.

### Packages only
```sh
ansible-playbook ansible/install-packages.yml
```

---

## Auto-run on shell login

The following snippet in `~/.bashrc` mirrors the `hm-bootstrapped` pattern and runs the full bootstrap once per machine:

```bash
if [[ ! -f /tmp/.ansible-bootstrapped ]]; then
  cd ~/dotfiles && ansible-playbook ansible/site.yml && touch /tmp/.ansible-bootstrapped
fi
```

On Nix/Coder machines this is managed via `home.nix` (`programs.bash.initExtra`).  
On plain Linux machines, add it manually to `~/.bashrc`.

---

## Notes

| Package | How installed |
|---|---|
| `ripgrep`, `jq`, `curl`, `htop`, `nodejs`, `gh`, `direnv`, `podman`, `kubectl` | system package manager |
| `bun` | official curl installer |
| `pnpm` | `npm install -g pnpm` |
| `fnm` | official curl installer |
| `home-manager` | Nix only — not installed via Ansible |
| `piCodingAgent` | Nix only — not installed via Ansible |
