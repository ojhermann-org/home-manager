Run a pre-PR checklist for the current repository, then open a PR if all checks pass.

## Checks

Run each check in order. Collect all warnings before deciding whether to proceed.

### 1. Branch

Confirm the current branch is not `main`. If it is, warn:

```
WARNING: You are on `main`. PRs must be opened from a feature branch.
```

### 2. Commit log

Run `git log --oneline main..HEAD` and display the output. This is informational — no warning, but the user must be able to review it.

### 3. Uncommitted changes

Run `git status --short`. If there is any output, warn:

```
WARNING: You have uncommitted or unstaged changes.
```

### 4. Merge conflicts

Search tracked files for conflict markers (`<<<<<<<`). If any are found, warn:

```
WARNING: Merge conflict markers found in: <file list>
```

### 5. Prek (if applicable)

If `prek.toml` exists in the repo root:

- Run `prek run -a`
- If any files were modified by prek, stage them and commit with message: `chore: apply prek auto-fixes`
- If prek exits non-zero and no files were auto-fixed (or still exits non-zero after committing fixes), warn:

```
WARNING: prek reported issues that require manual fixes.
```

## After checks

- **No warnings**: run `gh pr create`.
- **Any warnings**: display a summary of all warnings and stop. Do not open the PR.
