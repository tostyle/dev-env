# home.nix — user environment configuration
# ─────────────────────────────────────────────────────────────────────────────
# `myUser` is injected from flake.nix via extraSpecialArgs.
# Activate with:
#   home-manager switch --flake .#<username>

{ pkgs, myUser, ... }:

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
    userName  = "Your Name";
    userEmail = "you@example.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase        = true;
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
    '';
  };

  # ── Packages ──────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    ripgrep
    jq
    curl
    htop
  ];

  # ── SSH ───────────────────────────────────────────────────────────────────
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname     = "github.com";
        user         = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  # ── direnv hook (so `direnv allow` works in every new shell) ──────────────
  programs.direnv = {
    enable            = true;
    nix-direnv.enable = true;  # caches nix develop shells
  };
}
