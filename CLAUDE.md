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
prek.toml          # Git hook configuration (see below)
.claude/
  settings.json    # Claude Code hook: runs nix flake update before gh pr create
programs/          # One .nix file per tool/program; each returns a HM module
  shell.nix        # Shell setup (zsh on Darwin, bash on Linux), aliases, switch scripts
  git.nix
  hx.nix           # Helix editor
  zellij.nix
  mise.nix
  direnv.nix
  prek.nix         # Installs prek
  ...
  shell/           # Scripts sourced by shell.nix (bash-init.sh, zsh-init.sh, etc.)
  hx/              # Helix config files (LSP, formatters, linters per language)
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

### Linking config files/dirs with `xdg.configFile`

Use `xdg.configFile` to symlink files or directories from the repo into
`~/.config/`:

```nix
xdg.configFile."zellij/layouts".source = ./zellij/layouts;
```

### Post-switch activation hooks

`home.activation` runs shell snippets after the config is applied. Use
`lib.hm.dag.entryAfter [ "writeBoundary" ]` to run after files are linked:

```nix
home.activation.sudoByTouch = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
  lib.hm.dag.entryAfter [ "writeBoundary" ] (builtins.readFile ./shell/scripts/sudo-by-touch.sh)
);
```

### Helix language configs (programs/hx/)

Each file under `programs/hx/` configures a language server/formatter for one
language. They are plain HM modules (auto-imported) that extend
`programs.helix.languages.language` and install the relevant tools into
`home.packages`. Example: `hx/nix.nix` installs `nil`, `nixd`, `nixfmt`,
`statix`, and `deadnix`, and configures auto-format on save.

## Custom commands installed by shell.nix

| Command      | Description |
|--------------|-------------|
| `switch`     | Apply latest `main` config from GitHub (platform-specific) |
| `gst`        | `git status -sb` + `tree` (or just `tree` outside a git repo) |
| `watch-dir`  | Run `gst` on every file change via `watchexec` |
| `new-py-dir` | Create a directory tree and add `__init__.py` to each new dir |
| `new-zsh`    | Scaffold a new zsh script file |
| `new-bash`   | Scaffold a new bash script file |

## Git hooks (prek)

[prek](https://github.com/j178/prek) manages git hooks via `prek.toml`. Hooks
run on commit. Install hooks after cloning:

```bash
prek install
```

### Builtin hooks

| Hook | Purpose |
|------|---------|
| `no-commit-to-branch` | Block direct commits to `main` |
| `trailing-whitespace` | Strip trailing whitespace |
| `end-of-file-fixer` | Ensure files end with a newline |
| `check-merge-conflict` | Reject unresolved conflict markers |
| `check-toml` | Validate TOML syntax |
| `check-json` | Validate JSON syntax |
| `detect-private-key` | Block accidental key commits |

### Local hooks

These run tools that are installed via home-manager packages:

| Hook | Tool | What it checks |
|------|------|----------------|
| `nixfmt` | `nixfmt` | Auto-formats Nix files in place |
| `statix` | `statix fix` | Auto-fixes Nix anti-patterns in place |
| `deadnix` | `deadnix --edit` | Auto-removes unused Nix bindings in place |
| `shellcheck` | `shellcheck` | Shell script correctness |

`statix` and `deadnix` are installed by `programs/hx/nix.nix`.
`shellcheck` is installed by `programs/shellcheck.nix`.

### Claude Code hook (`.claude/settings.json`)

Before any `gh pr create` command, Claude automatically runs `nix flake update`
from the repo root to ensure the lock file is current before the PR is opened.

## Supported systems

| Attribute                        | System         |
|----------------------------------|----------------|
| `otto@aarch64-darwin`            | macOS (Apple Silicon) |
| `otto@x86_64-linux`              | Linux (x86)    |
| `otto@aarch64-linux`             | Linux (ARM64)  |

## Workflow

### Before merging a PR

Run `switch` locally to verify the config applies cleanly before merging.

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

## Default dev environment (Zellij `basic` layout)

Running `zellij` (or `zj`) opens the `basic` layout, which is the standard
working environment:

```
┌─────────────────────────────────────────────────────┐
│  tab-bar                                             │
├────────────────────┬────────────────────────────────┤
│                    │  hx     (50%)                   │
│  claude (40%)      ├────────────────────────────────┤
│                    │  zsh    (50%)   ← focus         │
├────────────────────┴────────────────────────────────┤
│  status-bar                                          │
└─────────────────────────────────────────────────────┘
```

`claude` occupies the left pane. `hx` and `zsh` share the right pane (60%)
vertically.

## Shell prompt

Both shells use the same custom prompt format:

```
user@host | path | YYYY-MM-DD HH:MM:SS | ⎇ branch
>
```

Branch indicator color: **green** = clean, **red** = dirty working tree.
Defined in `shell/scripts/zsh-init.sh` (zsh) and `shell/scripts/bash-init.sh`
(bash).

## Important notes

- **`home.stateVersion`** (`"25.11"` in `home.nix`) must not be changed even
  when upgrading Home Manager. It tracks the format of state files on disk, not
  the HM version.
- **`nixpkgs` follows `nixos-unstable`** — packages are always from the latest
  unstable channel.
- **`inputs.nixpkgs.follows`** in `flake.nix` ensures Home Manager and the top-
  level config share the same nixpkgs, avoiding duplicate package sets.
- **Editor**: `EDITOR` and `VISUAL` are set to `hx` (Helix).
- **`sudo-by-touch`** (Darwin only) — the post-activation hook edits
  `/etc/pam.d/sudo_local` to enable Touch ID for `sudo`. It requires `sudo`
  access and runs automatically after every `switch`.
- **`new-zsh` / `new-bash`** create a file at the given path (including any
  missing parent directories) pre-populated with a shebang and
  `# shellcheck shell=bash` directive.
- **Shell history** is capped at 200 entries with `ignoredups` on both shells.
