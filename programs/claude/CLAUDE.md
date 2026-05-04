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

New repositories for the `ojhermann-org` organization are created via the `/new-repo` skill, which handles the github-settings PR, the Apply workflow, and the initial scaffolding (Nix flake, prek, Helix config, CI). Do not create repos via the GitHub UI, and do not edit `ojhermann-org/github-settings` by hand to add a repo unless `/new-repo` is unavailable.

When making other changes to `ojhermann-org/github-settings` (org settings, modules, ruleset edits, etc.), always run `tofu init`, `tofu validate`, and `tofu plan` before committing. After merging, trigger the Apply workflow via the Actions tab — it is `workflow_dispatch`-only and does not run automatically on merge.

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
