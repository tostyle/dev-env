# home.nix — user environment configuration
# ─────────────────────────────────────────────────────────────────────────────
# `myUser` is injected from flake.nix via extraSpecialArgs.
# Activate with:
#   home-manager switch --flake .#<username>

{ pkgs, myUser, lib, ... }:

{
  # ── Required home-manager settings ────────────────────────────────────────
  home.username      = myUser;
  home.homeDirectory = if pkgs.stdenv.isDarwin
                       then "/Users/${myUser}"
                       else "/home/${myUser}";
  home.stateVersion  = "24.11"; # do not change after first switch

  # ── Git ───────────────────────────────────────────────────────────────────
  # programs.git = {
  #   enable    = true;
  #   userName  = "Your Name";
  #   userEmail = "you@example.com";

  #   extraConfig = {
  #     init.defaultBranch = "main";
  #     pull.rebase        = true;
  #   };
  # };

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
    '';
  };

  # ── Packages ──────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    ripgrep
    jq
    curl
    htop
    # ── dev tools (always available, not just in nix develop) ──────────────
    podman
    bun
    pnpm
    nodejs
    kubectl
    home-manager
    gh
    fnm
    direnv
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
  home.activation.postInstall = lib.hm.dag.entryAfter [ "installPackages" ] ''
    echo "packages installed, running post-install script..." && \
    source ~/.bashrc && \
    echo "post-install script completed."
  '';

  home.activation.installPI = lib.hm.dag.entryAfter [ "installPackages" ] ''
    export PNPM_HOME="$HOME/.local/share/pnpm"
    mkdir -p "$PNPM_HOME"
    export PATH="${pkgs.pnpm}/bin:${pkgs.nodejs}/bin:$PNPM_HOME:$PATH"
    echo "Installing pi-coding-agent via pnpm..."
    pnpm install -g @mariozechner/pi-coding-agent
    echo "pi-coding-agent installed."
  '';

  # ── direnv hook (so `direnv allow` works in every new shell) ──────────────
  programs.direnv = {
    enable            = true;
    nix-direnv.enable = true;  # caches nix develop shells
  };
}
