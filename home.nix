# home.nix — user environment configuration
# ─────────────────────────────────────────────────────────────────────────────
# `myUser` is injected from flake.nix via extraSpecialArgs.
# Activate with:
#   home-manager switch --flake .#<username>

{ pkgs, myUser, lib, gitName, gitEmail, llm-agents, ... }:

let
  agentPkgs = llm-agents.packages.${pkgs.system};
in
{
  # imports = [ hermes-agent.homeManagerModules.default ];
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
    enable            = false;
    enableCompletion  = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable  = true;
      plugins = [ "git" "kubectl" "docker" ];
      theme   = "robbyrussell";
    };

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
      export PATH="$HOME/.nix-profile/bin:$HOME/.local/bin:$PATH"
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

      envsource() {
        local env_file="''${1:-.env}"
        if [[ ! -f "$env_file" ]]; then
          echo "envsource: file not found: $env_file" >&2
          return 1
        fi
        set -a
        source "$env_file"
        set +a
        awk -F'=' '{print "export " $1 "=****"}' "$env_file"
      }
    '';
  };

  programs.tmux = {
    enable = false;
    shortcut = "a"; # Sets prefix key to Ctrl-a
  };

  # ── Packages ──────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    bat
    fzf
    fd
    ripgrep
    jq
    sqlite
    curl
    cron
    htop
    # podman
    bun
    pnpm
    nodejs
    kubectl
    kubernetes-helm
    minikube
    k9s
    home-manager
    gh
    fnm
    direnv
    ansible
    yazi
    lazygit
    lazydocker
    neovim
    xclip
  ]
  # AI coding agents from github:numtide/llm-agents.nix
  # (pi replaces the deprecated @mariozechner/pi-coding-agent custom derivation)
  ++ [
    agentPkgs.pi
    agentPkgs.herdr
  ]
  # Hermes Agent CLI is installed via Ansible (ansible/hermes-agent.yml) using
  # the official installer: curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
  ;

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

  # ── zoxide (smarter `cd`; adds the `z` function to bash) ──────────────────
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  # ── direnv hook (so `direnv allow` works in every new shell) ──────────────
  programs.direnv = {
    enable            = true;
    nix-direnv.enable = true;  # caches nix develop shells
  };

  # ── Hermes Agent (installed via Ansible) ────────────────────────────────
  # Previously provided declaratively by the hermes-agent Home Manager module.
  # Now installed with the official installer through ansible/hermes-agent.yml:
  #   curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
  # programs.hermes-agent.enable = true;
  # services.hermes-agent = { ... };
}
