{
  description = "Development environment — podman, git, nvm, node, bun, pnpm";

  inputs = {
    # nixos-unstable gives us the latest package versions
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # flake-utils lets us support multiple CPU architectures cleanly
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    # Build the devShell for every supported system (x86_64-linux, aarch64-linux, etc.)
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
            nvm     # Node Version Manager shell script
            bun     # fast JS runtime & package manager
            pnpm    # efficient Node package manager
          ];

          # ---------- shellHook: runs every time you enter `nix develop` ----------
          shellHook = ''
            export NVM_DIR="$HOME/.nvm"
            mkdir -p "$NVM_DIR"

            # Symlink nvm.sh from the Nix store into NVM_DIR.
            # This makes the standard nvm init line in .bashrc work:
            #   [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
            # ln -sf is used so the symlink is always refreshed after nix updates.
            ln -sf "${pkgs.nvm}/nvm.sh" "$NVM_DIR/nvm.sh"

            # Activate nvm in the current shell session
            source "${pkgs.nvm}/nvm.sh"
          '';
        };
      }
    );
}
