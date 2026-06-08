# home.nix — user environment configuration
# ─────────────────────────────────────────────────────────────────────────────
# `myUser` is injected from flake.nix via extraSpecialArgs.
# Activate with:
#   home-manager switch --flake .#<username>

{ pkgs, myUser, lib, gitName, gitEmail, ... }:

let
  piCodingAgent = pkgs.callPackage ./pkgs/pi-coding-agent.nix { inherit lib; };
in
{
  # ── Required home-manager settings ────────────────────────────────────────
  home.username      = myUser;
  home.homeDirectory = if pkgs.stdenv.isDarwin
                       then "/Users/${myUser}"
                       else "/home/${myUser}";
  home.stateVersion  = "24.11"; # do not change after first switch

  # ── Git ───────────────────────────────────────────────────────────────────
  programs.git = {
    enable    = true;
    settings = {
      user.name  = gitName;
      user.email = gitEmail;
      init.defaultBranch = "main";
      pull.rebase        = false;
    };
  };

  # ── Shell (zsh) ───────────────────────────────────────────────────────────
  programs.zsh = {
    enable            = true;
    enableCompletion  = true;
    autosuggestion.enable = true;

    shellAliases = {
      ll  = "ls -la";
      g   = "git";
      k   = "kubectl";
    };

    envExtra = ''
      export KUBECONFIG="$HOME/.kube/config"
      export PNPM_HOME="$HOME/.local/share/pnpm"
      export PATH="$PNPM_HOME:$PATH"
    '';
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      export PATH="$HOME/.nix-profile/bin:$PATH"
      export PNPM_HOME="$HOME/.local/share/pnpm"
      export PATH="$PNPM_HOME:$PATH"
      export NPM_CONFIG_PREFIX="$HOME/.local"
      # if [[ ! -f /tmp/.hm-bootstrapped ]]; then
      #   cd ~/dotfiles && bash bootstrap.sh && touch /tmp/.hm-bootstrapped
      # fi
      # if [[ -f "$HOME/.bashrc" ]]; then
      #   source "$HOME/.bashrc"
      # fi
      # if [[ ! -f /tmp/.ansible-bootstrapped ]]; then
      #   cd ~/dotfiles && ansible-playbook ansible/site.yml && touch /tmp/.ansible-bootstrapped
      # fi
    '';
  };

  programs.tmux = {
    enable = false;
    shortcut = "a"; # Sets prefix key to Ctrl-a
  };

  # ── Packages ──────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    ripgrep
    jq
    curl
    htop
    # podman
    bun
    pnpm
    nodejs
    kubectl
    home-manager
    gh
    fnm
    direnv
    ansible
    yazi
    lazygit
    lazydocker
    # piCodingAgent
    # distrobox
  ];

  # ── SSH ───────────────────────────────────────────────────────────────────
  # programs.ssh = {
  #   enable = true;
  #   matchBlocks = {
  #     "github.com" = {
  #       hostname     = "github.com";
  #       user         = "git";
  #       identityFile = "~/.ssh/id_ed25519";
  #     };
  #   };
  # };

  # ── Default shell → zsh ───────────────────────────────────────────────────
  # home.activation.setDefaultShell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #   if [ "$(getent passwd ${myUser} | cut -d: -f7)" != "${pkgs.zsh}/bin/zsh" ]; then
  #     run chsh -s ${pkgs.zsh}/bin/zsh ${myUser}
  #   fi
  # '';
  # ── direnv hook (so `direnv allow` works in every new shell) ──────────────
  programs.direnv = {
    enable            = true;
    nix-direnv.enable = true;  # caches nix develop shells
  };
}
