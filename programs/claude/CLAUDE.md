# Global Claude Code guidance

<!-- Preferences, conventions, and instructions that apply across all projects. -->

## Git workflow

Unless instructed otherwise, all changes must be committed on a branch other than `main` and merged via a PR. Prefer small, focused PRs over larger ones. After merging a PR, return to `main` and delete the local branch that was just merged.

## Git hooks

Each repo must include a `prek.toml` to manage pre-commit hooks via [prek](https://github.com/j178/prek). After creating `prek.toml`, run `prek install` to activate the hooks.

Every `prek.toml` should include these builtins at minimum:

```toml
[[repos]]
repo = "builtin"
hooks = [
  {id = "no-commit-to-branch"},
  {id = "trailing-whitespace"},
  {id = "end-of-file-fixer"},
  {id = "check-merge-conflict"},
  {id = "check-toml"},
  {id = "check-json"},
  {id = "check-yaml"},
  {id = "check-xml"},
  {id = "check-added-large-files"},
  {id = "check-case-conflict"},
  {id = "mixed-line-ending"},
  {id = "detect-private-key"},
]
```

Add local hooks as appropriate for the languages in the repo (e.g. `nixfmt`/`statix`/`deadnix` for Nix, `shellcheck` for shell scripts). See `ojhermann/home-manager` for examples.

## GitHub repositories

New repositories for the `ojhermann-org` organization are created by adding them to `ojhermann-org/github-settings` (managed with OpenTofu) and running `tofu apply`. Do not create repos via the GitHub UI.

Before creating a new repo, confirm with the user:
- **Visibility**: public or private?
- **CI**: should a GitHub Actions workflow be added at creation to run prek's builtin hooks on PRs? Default to yes — it guards against contributors who skip `prek install` locally. If yes, add the workflow to the new repo as part of the same setup, running `prek run --all-files`.

When making changes to `ojhermann-org/github-settings`, always run `tofu init`, `tofu validate`, and `tofu plan` before committing. Ask the user to run `tofu apply` after merging (this can be done via the GitHub Actions UI).

New repositories default to Nix flakes as the package manager unless the user specifies otherwise. When using Nix flakes, add a `.envrc` containing `use flake` so direnv activates the environment automatically.

## Helix editor

Helix (`hx`) is Otto's default editor. When setting up a new project where the language is known:

1. Add the language's language server(s) to the flake as dev dependencies.
2. Add a `.helix/languages.toml` to the repo configuring the language server(s) explicitly — this makes the setup reproducible for other Helix users.
3. Recommend a formatter to Otto and wait for his approval before adding it. Once approved, add it to the flake and wire it into `.helix/languages.toml`.

See `ojhermann/home-manager` under `programs/hx/` for examples of language server and formatter configuration.

## Configuration management

Config, dotfiles, and tooling are managed via Home Manager in the `ojhermann/home-manager` repo. Barring exceptional circumstances, changes should be made there rather than editing files directly.

## Working environment

Otto is almost always working inside Zellij. Prefer Zellij-native suggestions (pane splits, tabs, layouts) over generic terminal advice.
