# home.nix — user environment configuration
# ─────────────────────────────────────────────────────────────────────────────
# `myUser` is injected from flake.nix via extraSpecialArgs.
# Activate with:
#   home-manager switch --flake .#<username>

{ pkgs, myUser, lib, gitName, gitEmail, llm-agents, hermes-agent, ... }:

let
  agentPkgs = llm-agents.packages.${pkgs.system};
in
{
  imports = [ hermes-agent.homeManagerModules.default ];
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
  ]
  # Hermes Agent CLI (declarative Home Manager service is also configured below)
  ++ [
    hermes-agent.packages.${pkgs.system}.default
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

  # ── Hermes Agent (Home Manager module) ──────────────────────────────────
  # Docs: https://github.com/NousResearch/hermes-agent/blob/main/website/docs/getting-started/nix-setup.md
  # This puts `hermes` on PATH and exports HERMES_HOME for the session.
  programs.hermes-agent.enable = true;

  # Hermes gateway user service. Set gateway.enable = true when you want the
  # long-running gateway (Telegram/Discord/Slack + cron). It needs at least one
  # LLM API key in an environment file (sops/agenix or a plain 0600 file).
  services.hermes-agent = {
    enable = true;
    gateway.enable = false; # flip to true once you have secrets configured

    # Example configuration — uncomment and adapt after adding secrets:
    # settings.model.default = "anthropic/claude-sonnet-4";
    # settings.toolsets = [ "all" ];

    # Never put API keys in Nix! Use sops-nix, agenix, or a plain file with
    # mode 0600, then reference it here:
    # environmentFiles = [ config.sops.secrets."hermes-env".path ];
  };
}
