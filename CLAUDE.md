# home-manager

[Home Manager](https://nix-community.github.io/home-manager/) configuration as
a Nix flake, targeting multiple systems under a single user (`otto`).

## Reference docs

- **Home Manager**: https://nix-community.github.io/home-manager/
- **Determinate Nix**: https://docs.determinate.systems/determinate-nix/
- **How Nix works**: https://nixos.org/guides/how-nix-works/
- **Nix guides**: https://nix.dev/guides/

## Repo structure

```
flake.nix          # Flake definition; declares inputs and homeConfigurations
home.nix           # Root HM module; auto-imports all .nix files under programs/
programs/          # One .nix file per tool/program; each returns a HM module
  shell.nix        # Shell setup (zsh on Darwin, bash on Linux), aliases, switch scripts
  git.nix
  hx.nix           # Helix editor
  zellij.nix
  mise.nix
  direnv.nix
  ...
  shell/           # Scripts sourced by shell.nix (bash-init.sh, zsh-init.sh, etc.)
  hx/              # Helix config files
  zellij/          # Zellij layout files
packages/          # Standalone Nix derivations imported by programs/
  gst.nix          # git status + tree combo script
  watch-dir.nix    # watchexec wrapper using gst
```

## Key patterns

### Auto-import of programs

`home.nix` recursively discovers and imports every `.nix` file under `programs/`
via `lib.filesystem.listFilesRecursive`. Adding a new file to `programs/` is
enough — no manual wiring needed.

### Platform-conditional config

Use `lib.mkIf` with `pkgs.stdenv.hostPlatform` predicates:

```nix
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin { ... }
lib.mkIf pkgs.stdenv.hostPlatform.isLinux  { ... }
lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86_64) { ... }
```

`shell.nix` uses this to pick the right `switch` script and shell (`zsh` on
Darwin, `bash` on Linux).

### Shell scripts via `writeShellApplication`

Custom commands are defined with `pkgs.writeShellApplication`, which provides
strict mode and dependency isolation:

```nix
pkgs.writeShellApplication {
  name = "my-cmd";
  runtimeInputs = [ pkgs.git pkgs.coreutils ];
  text = ''
    echo "hello"
  '';
}
```

Add the derivation to `home.packages` to install it.

### Standalone packages (packages/)

Derivations in `packages/` take explicit arguments (e.g., `{ pkgs }` or
`{ pkgs, gst }`) and are imported manually inside `programs/` files:

```nix
let
  gst = import ../packages/gst.nix { inherit pkgs; };
in { ... }
```

## Supported systems

| Attribute                        | System         |
|----------------------------------|----------------|
| `otto@aarch64-darwin`            | macOS (Apple Silicon) |
| `otto@x86_64-linux`              | Linux (x86)    |
| `otto@aarch64-linux`             | Linux (ARM64)  |

## Workflow

### Local development / testing

```bash
home-manager switch --flake .#otto@aarch64-darwin
```

Use the appropriate attribute for the current machine. The `--refresh` flag
avoids stale git caches when pulling from a remote flake.

### Normal use (deployed machines)

Running `switch` in the terminal applies the latest `main` branch from GitHub:

```bash
switch   # alias for: home-manager switch --flake github:ojhermann/home-manager#otto@<system> --refresh
```

This script is installed by `shell.nix` and is platform/arch-specific.

## Important notes

- **`home.stateVersion`** (`"25.11"` in `home.nix`) must not be changed even
  when upgrading Home Manager. It tracks the format of state files on disk, not
  the HM version.
- **`nixpkgs` follows `nixos-unstable`** — packages are always from the latest
  unstable channel.
- **`inputs.nixpkgs.follows`** in `flake.nix` ensures Home Manager and the top-
  level config share the same nixpkgs, avoiding duplicate package sets.
- **Editor**: `EDITOR` and `VISUAL` are set to `hx` (Helix).
- **`/opt/pel/formae/bin`** is on `home.sessionPath` (machine-specific tooling).
