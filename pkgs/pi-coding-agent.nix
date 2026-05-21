# Custom derivation for @mariozechner/pi-coding-agent (not in nixpkgs).
#
# NOTE: This package is deprecated upstream. The author recommends using
#       @earendil-works/pi-coding-agent instead going forward.
#
# How to update hashes when bumping the version:
#
#   1. Src hash — run:
#        nix-prefetch-url --type sha256 \
#          https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-<version>.tgz
#
#   2. npmDepsHash — extract the tarball, generate a lock file, then hash it:
#        mkdir /tmp/pi-pkg && cd /tmp/pi-pkg
#        curl -sL https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-<version>.tgz | tar xz
#        cd package
#        npm install --package-lock-only --ignore-scripts --legacy-peer-deps
#        nix run nixpkgs#prefetch-npm-deps -- package-lock.json
#
#   Alternatively, set both hashes to lib.fakeHash first, run `home-manager switch`,
#   and nix will print the correct hash in the error message.

{ pkgs, lib, ... }:

pkgs.buildNpmPackage rec {
  pname   = "pi-coding-agent";
  version = "0.73.1";

  src = pkgs.fetchurl {
    url  = "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = lib.fakeHash; # replace after running nix-prefetch-url (see above)
  };

  # npm tarballs always unpack into a subdirectory called "package/"
  sourceRoot = "package";

  # Hash of all npm dependencies resolved from package.json.
  # Compute with `nix run nixpkgs#prefetch-npm-deps -- package-lock.json` (see above).
  npmDepsHash = lib.fakeHash;

  # The dist/ directory is already compiled — no build step needed.
  dontNpmBuild = true;

  meta = with lib; {
    description = "PI coding-agent CLI (pi command)";
    homepage    = "https://github.com/badlogic/pi-mono";
    license     = licenses.mit;
    mainProgram = "pi";
  };
}
