# Custom Nix Packages

This directory contains custom nix derivations for packages not available in
nixpkgs. Each package is a `.nix` file that can be loaded with `pkgs.callPackage`.

## How to add a new package

### 1. Create the derivation file

Create `pkgs/<name>.nix`. Choose the right builder for the ecosystem:

| Package type | Builder |
|---|---|
| npm CLI tool | `pkgs.buildNpmPackage` |
| Generic tarball / pre-built binary | `pkgs.stdenv.mkDerivation` |
| Go module | `pkgs.buildGoModule` |
| Python package | `pkgs.python3Packages.buildPythonPackage` |

### 2. Wire it into home.nix

In `home.nix`, load it with `callPackage` and add it to `home.packages`:

```nix
let
  myTool = pkgs.callPackage ./pkgs/my-tool.nix { inherit lib; };
in {
  home.packages = [ myTool ];
}
```

### 3. Apply

```bash
bash setup-nix.sh
# or
home-manager switch --flake .#coder
```

---

## npm packages (`buildNpmPackage`)

Use this for any CLI tool published to the npm registry.

### Template

```nix
{ pkgs, lib, ... }:

pkgs.buildNpmPackage rec {
  pname   = "my-tool";
  version = "1.2.3";

  src = pkgs.fetchurl {
    url  = "https://registry.npmjs.org/@scope/my-tool/-/my-tool-${version}.tgz";
    hash = lib.fakeHash; # replace after first build
  };

  sourceRoot = "package"; # npm tarballs always unpack into package/

  # npm tarballs don't include package-lock.json — vendor one (see below)
  postPatch = ''
    cp ${./my-tool-package-lock.json} package-lock.json
  '';

  npmDepsHash = lib.fakeHash; # replace after first build

  # Only needed if package has compiled output already (no build step)
  dontNpmBuild = true;

  meta = with lib; {
    description = "My tool description";
    homepage    = "https://github.com/...";
    license     = licenses.mit;
    mainProgram = "my-tool"; # the binary name
  };
}
```

### Getting the hashes

**Src hash** — hash of the raw downloaded tarball:

```bash
nix store prefetch-file \
  "https://registry.npmjs.org/@scope/my-tool/-/my-tool-1.2.3.tgz"
# prints: hash 'sha256-...'
```

**npmDepsHash** — hash of the offline npm dependency cache built from the lock file.

First generate the lock file (npm tarballs don't include one):

```bash
mkdir /tmp/pkg && cd /tmp/pkg
curl -sL https://registry.npmjs.org/@scope/my-tool/-/my-tool-1.2.3.tgz | tar xz
cd package
nix shell nixpkgs#nodejs --command npm install \
  --package-lock-only --ignore-scripts --legacy-peer-deps
cp package-lock.json /path/to/dotfiles/pkgs/my-tool-package-lock.json
```

Then hash it:

```bash
nix run nixpkgs#prefetch-npm-deps -- pkgs/my-tool-package-lock.json
# prints: sha256-...
```

**Shortcut — use `lib.fakeHash` for both**, then run `home-manager switch`.
Nix will fail and print the correct hash in the error output:

```
specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
got:       sha256-c3pYEVIz5VWsaExwnagn2z8Jhh/Ltw3f0FAyVzZdk6M=
```

Copy the `got:` value.

### Common issues

**`ERROR: No lock file!`**
The npm tarball doesn't include `package-lock.json`. Generate one and vendor it
via `postPatch` as shown above.

**`npm error ENOTCACHED` / peer dep errors**
Add `npmFlags = [ "--legacy-peer-deps" ];` to the derivation.

**Files not tracked by nix / flake error**
Any file referenced in a derivation (including vendored lock files) must be
tracked by git:
```bash
git add pkgs/my-tool-package-lock.json pkgs/my-tool.nix
```

---

## Example: `pi-coding-agent`

See [pi-coding-agent.nix](./pi-coding-agent.nix) — a real-world example of a
deprecated npm CLI tool that:
- fetches its tarball from the npm registry
- vendors a generated `package-lock.json` via `postPatch`
- skips the build step because `dist/` is pre-compiled
- uses `--legacy-peer-deps` to handle an optional peer dependency
