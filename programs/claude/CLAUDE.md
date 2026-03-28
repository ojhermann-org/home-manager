# Global Claude Code guidance

<!-- Preferences, conventions, and instructions that apply across all projects. -->

## Git workflow

Unless instructed otherwise, all changes must be committed on a branch other than `main` and merged via a PR. Prefer small, focused PRs over larger ones. After merging a PR, return to `main` and delete the local branch that was just merged.

## Git hooks

Each repo should include a `prek.toml` to manage pre-commit hooks via [prek](https://github.com/j178/prek). The `ojhermann/home-manager` repo is a good reference for hook configuration.

## Configuration management

Config, dotfiles, and tooling are managed via Home Manager in the `ojhermann/home-manager` repo. Barring exceptional circumstances, changes should be made there rather than editing files directly.

## Working environment

Otto is almost always working inside Zellij. Prefer Zellij-native suggestions (pane splits, tabs, layouts) over generic terminal advice.
