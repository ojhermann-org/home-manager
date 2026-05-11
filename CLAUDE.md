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
  hx.nix           # Helix editor (top-level config)
  zellij.nix
  direnv.nix
  prek.nix         # Installs prek (hook runner)
  ...
  shell/           # Scripts sourced by shell.nix (bash-init.sh, zsh-init.sh, etc.)
  hx/              # Helix-specific config per language (programs.helix.languages.*)
  lsp/             # Language servers per language (editor-agnostic)
  code-quality/    # Formatters + linters per language (editor-agnostic)
  zellij/          # Zellij layout files
packages/          # Standalone Nix derivations and lists imported by programs/ and flake.nix
  code-quality-tools/  # Per-language lists of formatters/linters; shared between HM + devShell
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

Files in `packages/` take explicit arguments (typically `{ pkgs }`) and
are imported manually from `programs/` files or `flake.nix`:

```nix
home.packages = import ../../packages/code-quality-tools/nix.nix { inherit pkgs; };
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

### Language tooling layout

Per-language tooling is split across three parallel directories so that
installation is decoupled from any specific editor:

- `programs/lsp/<lang>.nix` — installs language servers (e.g. `nil`, `nixd`).
- `programs/code-quality/<lang>.nix` — installs formatters and linters.
  Each file is a thin HM module that consumes the shared list at
  `packages/code-quality-tools/<lang>.nix`.
- `programs/hx/<lang>.nix` — Helix-specific wiring only
  (`programs.helix.languages.*`). Does not install packages.

A new language follows the same template across all three locations. Tools
referenced by Helix config (e.g. `command = "nixfmt"`) resolve via PATH from
whichever module installs them.

### Shared code-quality lists (packages/code-quality-tools/)

Each `<lang>.nix` returns a list of packages, e.g.:

```nix
{ pkgs }: [ pkgs.nixfmt pkgs.statix pkgs.deadnix ]
```

These lists are the single source of truth, consumed by two places:

- `programs/code-quality/<lang>.nix` — adds them to `home.packages`.
- `flake.nix` devShell — adds them to `buildInputs`.

This means `nix develop` on a fresh clone gets the full set of code-quality
tools (plus `prek`) without needing `home-manager switch` first, which is
what makes the prek hooks runnable in CI and bootstrap contexts.

### DevShell (`nix develop`)

`flake.nix` exposes a `default` devShell per system containing `prek` and
every tool listed under `packages/code-quality-tools/`. The shell's
`shellHook` runs `prek install` if the repo's pre-commit hook isn't already
in place, so entering the shell on a fresh clone is enough to activate hooks.

## Custom commands installed by shell.nix

| Command      | Description |
|--------------|-------------|
| `switch`     | Apply latest `main` config from GitHub (platform-specific) |

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

All four are installed via the per-language code-quality lists under
`packages/code-quality-tools/` (`nix.nix` for `nixfmt`/`statix`/`deadnix`,
`bash.nix` for `shellcheck`). These lists are consumed by both
`programs/code-quality/<lang>.nix` and the flake's devShell.

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
- **Shell history** is capped at 200 entries on both shells. zsh uses
  `ignoreAllDups`, `ignoreSpace`, `expireDuplicatesFirst`, `share`, and
  `extended` (timestamps). bash uses `erasedups` and `ignorespace` —
  the nearest analogues the HM `programs.bash` module exposes.
  Note: `history` in zsh shows only the last 15 entries by default; use
  `history 1` (or `history -i 1` for timestamps) to see the full file.
