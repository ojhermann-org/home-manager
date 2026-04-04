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

## Configuration management

Config, dotfiles, and tooling are managed via Home Manager in the `ojhermann/home-manager` repo. Barring exceptional circumstances, changes should be made there rather than editing files directly.

## Working environment

Otto is almost always working inside Zellij. Prefer Zellij-native suggestions (pane splits, tabs, layouts) over generic terminal advice.
