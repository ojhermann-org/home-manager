Create a new repository in the `ojhermann-org` GitHub organization end-to-end: register it via tofu in `~/Documents/github-settings`, pause for the user to merge and run the Apply workflow, then clone and scaffold the new repo locally.

This skill assumes the `standard_repo` module in `~/Documents/github-settings/modules/standard_repo` exposes a `license_template` input (added in PR #46). Branch protection, CODEOWNERS, and the required `ci` status check are handled by the org-level ruleset in `organization.tf` — this skill does not configure them per-repo.

## Phase 1: Pre-flight

Run all of the following. Stop and report any failure before prompting the user for inputs.

1. **Tools on PATH**: `gh`, `tofu`, `prek`, `git`, `direnv`, `nix`. (`command -v <tool>` for each.)
2. **gh authenticated**: `gh auth status` exits zero.
3. **R2 / S3 backend creds**: both `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set in the environment. Tofu cannot init the github-settings backend without them. If missing, instruct the user to export their R2 keys.
4. **github-settings checkout**: `~/Documents/github-settings` exists, is a clean working tree, and is on `main`. If not on main or not clean, stop.
5. **home-manager checkout**: `~/Documents/home-manager/prek.toml` exists. This file is the source of truth for the prek config copied into new repos.

## Phase 2: Inputs

Prompt the user for the following. Use the defaults shown unless the user overrides. After collecting, display a summary and ask the user to confirm before continuing.

| Input | Required | Default | Notes |
|---|---|---|---|
| `name` | yes | — | GitHub repo name. Must match `^[a-z][a-z0-9-]*$` and not already exist as a module in `repositories.tf`. |
| `description` | no | empty | One-sentence description shown on the repo page. |
| `visibility` | no | `public` | `public` or `private`. |
| `license_template` | no | `apache-2.0` | GitHub license keyword (e.g. `mit`, `apache-2.0`, `gpl-3.0`). |
| `homepage_url` | no | empty | Optional URL for the repo homepage. |
| `topics` | no | empty | Comma-separated list of GitHub topic tags (e.g. `nix,home-manager,dotfiles`). Used for discoverability — especially worth setting on public repos. Each topic must match GitHub's rules (lowercase, alphanumeric, hyphens, max 50 chars). |
| `language` | no | `nix-flake` | `nix-flake` (default scaffolding) or `none` (CI + prek only). |
| `use_direnv` | no | `yes` | `yes` adds a `.envrc` and runs `direnv allow` after scaffolding. With `language == "nix-flake"` the `.envrc` contains `use flake` so the dev shell activates on `cd`. |

### Name validation

- Must match `^[a-z][a-z0-9-]*$`.
- Run `grep -E 'name\s*=\s*"<name>"' /Users/otto/Documents/github-settings/repositories.tf`. If it matches, stop with: `Repo name "<name>" already registered in repositories.tf.`
- Run `gh repo view ojhermann-org/<name> --json name 2>/dev/null` — if it returns a result, the repo already exists on GitHub. Stop.
- If `~/Documents/<name>` already exists locally, stop with: `~/Documents/<name> already exists. Move or delete it before creating a new repo with this name.`

## Phase 3: github-settings PR

Operate in `~/Documents/github-settings`. Stop on any failure.

1. `git -C ~/Documents/github-settings pull --ff-only`.
2. `git -C ~/Documents/github-settings checkout -b feat/<name>`. (The `feat/` prefix satisfies the per-repo branch naming ruleset on github-settings.)
3. Append a module entry to `repositories.tf`. Use the standard_repo module. **Omit any field whose value equals the module default** so the file stays minimal:

   ```hcl
   module "<name_underscored>" {
     source           = "./modules/standard_repo"
     name             = "<name>"
     description      = "<description>"        # omit if empty
     visibility       = "<visibility>"         # omit if "public"
     license_template = "<license_template>"   # omit if "apache-2.0"
     homepage_url     = "<homepage_url>"       # omit if empty
     topics           = ["<t1>", "<t2>"]       # omit if no topics provided
   }
   ```

   `<name_underscored>` is `<name>` with hyphens replaced by underscores (matches the existing convention in `repositories.tf`).

4. Run `tofu fmt`, then `tofu init`, then `tofu validate`, then `tofu plan -out=tfplan`.
5. Display the plan output. Expect exactly:
   - One new `module.<name>.github_repository.repo`.
   - One new `module.<name>.github_repository_ruleset.branch_naming`.
   - One new `module.<name>.github_repository_file.codeowners[0]` (unless the user explicitly set `create_codeowners = false`, which this skill does not currently support).
   - **No changes** to any existing module.

   If the plan touches an unrelated resource, stop and report. Do not commit.

6. Ask the user to confirm the plan before committing.
7. Commit with message `feat: add <name> repository`. Use a HEREDOC body that lists the inputs (visibility, license, description) and notes that the plan was clean.
8. `git -C ~/Documents/github-settings push -u origin feat/<name>`.
9. `gh pr create --title "feat: add <name> repository" --body "..."`. Body should summarise the inputs and link to the plan summary.
10. **Pause for merge.** Display:

    ```
    Merge https://github.com/ojhermann-org/github-settings/pull/<N>, then reply when done.
    I will trigger and watch the Apply workflow once you confirm.
    ```

    Do not proceed until the user confirms the merge.

## Phase 4: Apply and verify

After the user confirms the merge:

1. Trigger the Apply workflow against `main`:
   ```
   gh workflow run apply.yml --repo ojhermann-org/github-settings --ref main
   ```
2. Wait a few seconds for the run to register, then capture the run ID:
   ```
   gh run list --repo ojhermann-org/github-settings --workflow=apply.yml --limit 1 --json databaseId,status,url
   ```
3. Stream the run to completion:
   ```
   gh run watch <run-id> --repo ojhermann-org/github-settings --exit-status
   ```
   `--exit-status` makes the command fail if the run fails. If it exits non-zero, stop and report the run URL — do not proceed to scaffolding.
4. Run the `post-pr` skill against `~/Documents/github-settings` (or do its steps manually: checkout main, `git up`, `git branch -D feat/<name>`).
5. Verify the repo now exists on GitHub: `gh repo view ojhermann-org/<name> --json name,visibility,licenseInfo`. Confirm visibility and license match the inputs.

If the workflow run shows the repo was not actually created (e.g. tofu-side error), stop and ask the user to investigate.

## Phase 5: Clone and scaffold

1. `git clone git@github.com:ojhermann-org/<name>.git ~/Documents/<name>`.
2. `cd ~/Documents/<name>` (or use `git -C ~/Documents/<name>` for git, absolute paths for file writes).
3. `git -C ~/Documents/<name> checkout -b chore/initial-scaffolding`.

If `language == "nix-flake"`, write all files in this section. If `language == "none"`, write only `prek.toml`, `.github/workflows/ci.yml`, `.gitignore` (just `.envrc.local`), and `CLAUDE.md` (skeleton without Nix references).

### `flake.nix`

```nix
{
  description = "<description>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.prek
            pkgs.nixfmt
            pkgs.statix
            pkgs.deadnix
            pkgs.shellcheck
          ];
          shellHook = ''
            if [ -f prek.toml ] && [ ! -f .git/hooks/pre-commit ]; then
              prek install
            fi
          '';
        };
      });
    };
}
```

Substitute `<description>` with the user's description (use `"TBD"` if empty).

### `.envrc`

Only write this file if `use_direnv == "yes"`.

- If `language == "nix-flake"`, the contents are:

  ```
  use flake
  ```

- If `language == "none"`, write a placeholder so `direnv allow` has something to permit:

  ```
  # Add direnv directives here. See https://direnv.net/man/direnv-stdlib.1.html
  ```

### `.gitignore`

Always include `.direnv/` even when `use_direnv == "no"`, so other contributors who do use direnv don't accidentally commit it.

```
.direnv/
.envrc.local
result
result-*
```

### `prek.toml`

Copy verbatim from the home-manager checkout (kept aligned with `~/.claude/CLAUDE.md`):

```
cp /Users/otto/Documents/home-manager/prek.toml /Users/otto/Documents/<name>/prek.toml
```

Do not embed the contents in the skill — copying ensures the new repo always picks up the latest aligned version.

### `.helix/languages.toml`

```toml
[[language]]
name = "nix"
auto-format = true
formatter = { command = "nixfmt" }
```

### `.github/workflows/ci.yml`

The `prek.toml` copied from home-manager has `language = "system"` hooks (`nixfmt`, `statix`, `deadnix`, `shellcheck`) that need those binaries on `PATH`. So the CI template differs by language: nix-flake repos run prek inside `nix develop` so the devShell provides the tools, with `magic-nix-cache-action` caching the closure across runs.

If `language == "nix-flake"`:

```yaml
name: CI

on:
  pull_request:

jobs:
  prek:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: DeterminateSystems/nix-installer-action@v21
      - uses: DeterminateSystems/magic-nix-cache-action@v13
      - run: nix develop -c prek run --all-files

  ci:
    needs: [prek]
    runs-on: ubuntu-latest
    if: always()
    steps:
      - name: Check all jobs passed
        run: |
          if [[ "${{ contains(needs.*.result, 'failure') }}" == "true" || "${{ contains(needs.*.result, 'cancelled') }}" == "true" ]]; then
            exit 1
          fi
```

If `language == "none"`:

```yaml
name: CI

on:
  pull_request:

jobs:
  prek:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: j178/prek-action@v2.0.0

  ci:
    needs: [prek]
    runs-on: ubuntu-latest
    if: always()
    steps:
      - name: Check all jobs passed
        run: |
          if [[ "${{ contains(needs.*.result, 'failure') }}" == "true" || "${{ contains(needs.*.result, 'cancelled') }}" == "true" ]]; then
            exit 1
          fi
```

The `ci` job is the required status check enforced by the org-level `default-branch` ruleset (`github-settings/organization.tf`). **Do not rename or remove it** — without a check named `ci` that succeeds, no PR can ever merge to `main`.

Why `nix develop` rather than `nix profile install`:
- **Single source of truth.** The flake's devShell defines the tool versions; CI and local dev use the same closure from the same `flake.lock`.
- **Magic-nix-cache caches the closure.** Subsequent CI runs pull the evaluated devShell from GitHub Actions cache rather than rebuilding/redownloading per-package.

### `CLAUDE.md`

```markdown
# <name>

<description>

## Reference docs

(Add language-specific reference links here as the project grows.)

## Repo structure

\`\`\`
flake.nix          # Nix devShell
prek.toml          # Pre-commit hooks
.helix/            # Helix editor config
.github/workflows/ # CI
\`\`\`

## Development

<DEV_SECTION>

Activate the git hooks once after cloning:

\`\`\`
prek install
\`\`\`
```

Substitute `<name>` and `<description>`. Replace the literal `\`\`\`` sequences with real triple backticks when writing the file (they are escaped here only to avoid breaking this skill's own markdown).

Replace `<DEV_SECTION>` with one of:

- `language == "nix-flake"` and `use_direnv == "yes"`:

  ```
  `direnv` picks up `.envrc` automatically. To enter the dev shell manually:

  \`\`\`
  nix develop
  \`\`\`
  ```

- `language == "nix-flake"` and `use_direnv == "no"`:

  ```
  Enter the dev shell with:

  \`\`\`
  nix develop
  \`\`\`
  ```

- `language == "none"`: omit the dev shell paragraph entirely; just keep the `prek install` line.

## Phase 6: Activate hooks and run prek

In `~/Documents/<name>`:

1. `prek install` — activates the hooks for this clone.
2. `direnv allow` — only if `use_direnv == "yes"`.
3. `prek run -a` — verifies the scaffolded files pass all hooks. If any file is auto-fixed, leave it staged for the upcoming commit.

If `prek run -a` fails after one round of auto-fixes, stop and report the error. Do not open the scaffolding PR with failing hooks.

## Phase 7: Open the scaffolding PR

1. `git -C ~/Documents/<name> add .`
2. `git -C ~/Documents/<name> commit -m "chore: initial scaffolding"` (use a HEREDOC body listing what was scaffolded).
3. `git -C ~/Documents/<name> push -u origin chore/initial-scaffolding`.
4. `gh pr create --title "chore: initial scaffolding" --body "..."`.

This is the first PR on the new repo, so CI is running for the very first time. The org-level ruleset requires the `ci` status check to pass and a CODEOWNERS review. Tell the user to wait for CI to go green, approve as the code owner, then merge — and run `/post-pr` afterward to clean up.

## Final report

After Phase 7 completes, display:

```
Repo `<name>` created.
  - github-settings PR:    <url> (merged, applied)
  - Repo:                  https://github.com/ojhermann-org/<name>
  - Local checkout:        ~/Documents/<name>
  - Scaffolding PR:        <url> (awaiting CI + merge)
```
