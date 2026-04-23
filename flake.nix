{
  description = "Development environment — podman, git, bun, pnpm";

  inputs = {
    # nixos-unstable gives us the latest package versions
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # flake-utils lets us support multiple CPU architectures cleanly
    flake-utils.url = "github:numtide/flake-utils";
    # home-manager manages user dotfiles and user-level packages
    # `inputs.nixpkgs.follows` means home-manager uses OUR nixpkgs pin
    # instead of fetching its own — keeps everything on the same version
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager }:
    let
      # ── Change these two values to match your machine ──────────────────────
      mySystem  = "aarch64-darwin"; # or "x86_64-linux", "x86_64-darwin", etc.
      myUser    = "coder";  # result of `whoami`
      # ────────────────────────────────────────────────────────────────────────

      mkHome = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${mySystem};
        extraSpecialArgs = { inherit myUser; };
        modules = [ ./home.nix ];
      };
    in
    # ── Per-architecture outputs (devShell) ──────────────────────────────────
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          # ---------- packages installed into the shell PATH ----------
          packages = with pkgs; [
            git     # version control
            podman  # rootless container runtime (Docker-compatible)
            bun     # fast JS runtime & package manager
            pnpm    # efficient Node package manager
            kubectl # Kubernetes CLI — apply RBAC manifests and manage clusters
            direnv  # auto-load .envrc when entering a directory
            nix-direnv # direnv extension: cache `nix develop` shells so they
                       # reload only when flake.lock changes, not every shell open
          ];

          # ---------- shellHook: runs every time you enter `nix develop` ----------
          shellHook = ''
            echo ""
            echo "  tip: run 'direnv allow' once so the shell auto-activates"
            echo "       next time you cd into this directory."
            echo ""
          '';
        };
      }
    ) // {
      # ── Per-user outputs (home-manager) ─────────────────────────────────────
      # These live *outside* eachDefaultSystem because they are tied to a specific
      # user+machine combination, not an architecture loop.
      #
      # Apply with:
      #   nix run nixpkgs#home-manager -- switch --flake .#${myUser}
      # or after home-manager is on your PATH:
      #   home-manager switch --flake .#${myUser}
      # homeConfigurations.${myUser} = mkHome;

      homeConfigurations = {
        "coder" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${mySystem};
          extraSpecialArgs = { inherit myUser; };
          modules = [ ./home.nix ];
        };
      };
    };
}
