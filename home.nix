# home.nix — user environment configuration
# ─────────────────────────────────────────────────────────────────────────────
# `myUser` is injected from flake.nix via extraSpecialArgs.
# Activate with:
#   home-manager switch --flake .#<username>

{ pkgs, myUser, lib, gitName, gitEmail, llm-agents, flyline, ... }:

let
  agentPkgs = llm-agents.packages.${pkgs.system};
  flylinePkg = flyline.packages.${pkgs.system}.default;
  flylineLib = "${flylinePkg}/lib/libflyline${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}";
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

  # These PATH guards let the Hermes installer's shell-wiring step detect
  # ~/.local/bin is already set up (it greps for `PATH=.*\.local/bin`) and
  # skip appending to these files — which are read-only HM store symlinks.
  programs.bash = {
    enable = true;
    shellAliases = {
      ls  = "eza --group-directories-first";
      ll  = "eza -la --group-directories-first";
      lt  = "eza --tree";
      supervisord   = "supervisord -c $HOME/.config/supervisor/supervisord.conf";
      supervisorctl = "supervisorctl -c $HOME/.config/supervisor/supervisord.conf";
    };
    profileExtra = ''
      case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
    '';
    # HM's .bash_profile is a fixed template (sources .profile/.bashrc) with no
    # override option; force our own below (home.file.".bash_profile") so it
    # carries the installer's PATH guard. Source lines match the HM default.
    initExtra = ''
      export PATH="$HOME/.nix-profile/bin:$HOME/.local/bin:$PATH"
      export PNPM_HOME="$HOME/.local/share/pnpm"
      export PATH="$PNPM_HOME:$PATH"
      export NPM_CONFIG_PREFIX="$HOME/.local"

      # Flyline: load the Bash readline replacement in interactive shells
      if [[ $- == *i* ]]; then
        enable -f ${flylineLib} flyline 2>/dev/null || true
        flyline suggestions --auto-suggest false --auto-suggest-inline true
      fi
      # if [[ ! -f /tmp/.hm-bootstrapped ]]; then
      #   cd ~/dotfiles && bash bootstrap.sh && touch /tmp/.hm-bootstrapped
      # fi
      # if [[ -f "$HOME/.bashrc" ]]; then
      #   source "$HOME/.bashrc"
      # fi
      # if [[ ! -f /tmp/.ansible-bootstrapped ]]; then
      #   cd ~/dotfiles && ansible-playbook ansible/site.yml && touch /tmp/.ansible-bootstrapped
      # fi

      # OSC 52 clipboard — works over SSH on headless boxes (no X needed);
      # the terminal (VS Code, kitty, Alacritty, ...) writes to the local clipboard.
      # Usage: echo 'content' | clip
      clip() { printf '\033]52;c;%s\007' "$(base64 -w0)"; }

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

    # HM's .bash_profile is a fixed template (sources .profile/.bashrc) with no
    # override option; force our own so it carries the installer's PATH guard.
    # Source lines match the HM default.
  };

  home.file.".bash_profile".source = lib.mkForce (pkgs.writeText "bash_profile" ''
      # include .profile if it exists
      [[ -f ~/.profile ]] && . ~/.profile

      # include .bashrc if it exists
      [[ -f ~/.bashrc ]] && . ~/.bashrc

      case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
    '');

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
    httpie
    eza
    uv
    stow
    python313Packages.supervisor
    flylinePkg
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

  # ── Supervisor (user-scoped process manager) ────────────────────────────
  # Config lives in $HOME: supervisord's default search path does NOT include
  # ~/.config, so the bash aliases below always pass -c explicitly.
  xdg.configFile."supervisor/supervisord.conf".text = ''
    [supervisord]
    logfile=%(ENV_HOME)s/.local/state/supervisor/supervisord.log
    logfile_maxbytes=10MB
    logfile_backups=5
    pidfile=%(ENV_HOME)s/.local/state/supervisor/supervisord.pid
    childlogdir=%(ENV_HOME)s/.local/state/supervisor
    nodaemon=false

    [unix_http_server]
    file=%(ENV_HOME)s/.local/state/supervisor/supervisor.sock

    [rpcinterface:supervisor]
    supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

    [supervisorctl]
    serverurl=unix://%(ENV_HOME)s/.local/state/supervisor/supervisor.sock

    [include]
    # Drop per-program .conf files here (e.g. myapp.conf with a [program:x] section)
    files = %(ENV_HOME)s/.config/supervisor/conf.d/*.conf
  '';

  # supervisord refuses to start if log/sock dirs don't exist; conf.d is an
  # include target so it must exist too. HM can't manage empty dirs, so mkdir.
  home.activation.supervisorDirs = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    mkdir -p "$HOME/.local/state/supervisor" "$HOME/.config/supervisor/conf.d"
  '';

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

  # ── Starship prompt ───────────────────────────────────────────────────────
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      character.success_symbol = "[➜](bold green)";
      character.error_symbol   = "[✗](bold red)";
    };
  };

  # ── Hermes Agent (installed via Ansible) ────────────────────────────────
  # Previously provided declaratively by the hermes-agent Home Manager module.
  # Now installed with the official installer through ansible/hermes-agent.yml:
  #   curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
  # programs.hermes-agent.enable = true;
  # services.hermes-agent = { ... };
}
