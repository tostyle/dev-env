{
  description = "Development environment — podman, git, bun, pnpm";

  # Only applied when running this flake directly (nix run/develop/build).
  # Consumers must add these to their own nix conf to get binary cache hits.
  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

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
    # nix packages for AI coding agents (pi, herdr, opencode, ...)
    # daily-updated flakes, provides prebuilt binaries via cache.numtide.com
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      # NOTE: no `follows` on nixpkgs — llm-agents.nix pins its own
      # nixpkgs-unstable; following ours can break their hashes/cache.
    };
    # Hermes Agent Nix flake (tier-2; provides Home Manager / NixOS modules)
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      # NOTE: hermes-agent pins its own nixpkgs; do not follow ours to keep
      # its uv2nix/python builds from breaking on our nixos-unstable pin.
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, llm-agents, hermes-agent }:
    let
      # ── Change these two values to match your machine ──────────────────────
      mySystem  = "aarch64-linux"; # or "x86_64-linux", "aarch64-darwin", "x86_64-darwin"
      myUser    = "coder";  # result of `whoami`
      # ────────────────────────────────────────────────────────────────────────

      # ── Private values (gitignored) — copy private.nix.example → private.nix
      env = if builtins.pathExists ./env.nix
                then import ./env.nix
                else {};
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
            helm    # Kubernetes package manager
            minikube # local Kubernetes cluster for development
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
          extraSpecialArgs = {
            inherit myUser;
            inherit llm-agents hermes-agent;
            gitName  = env.gitName  or myUser;
            gitEmail = env.gitEmail or myUser;
          };
          modules = [ ./home.nix ];
        };
      };
    };
}
