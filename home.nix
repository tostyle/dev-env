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
    enable = false;
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
    bat
    zoxide
    fzf
    fd
    ripgrep
    jq
    curl
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

  # ── direnv hook (so `direnv allow` works in every new shell) ──────────────
  programs.direnv = {
    enable            = true;
    nix-direnv.enable = true;  # caches nix develop shells
  };
}
