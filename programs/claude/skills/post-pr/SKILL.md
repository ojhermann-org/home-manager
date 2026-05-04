Run post-merge cleanup after a PR is merged: return to `main`, pull, and delete the local branch.

## Checks

Run each check in order. Stop and report before mutating state if any precondition fails.

### 1. Branch

Determine the branch to clean up:

- If the current branch is not `main`, use it as `<branch>`.
- If the current branch is `main`, stop and warn:

```
WARNING: You are on `main`. Re-run this from the merged feature branch.
```

### 2. PR state

Run `gh pr view --json state,mergedAt,headRefName,number,title` for `<branch>`. If `state` is not `MERGED`, stop and warn:

```
WARNING: PR for `<branch>` is not merged (state: <state>). Aborting cleanup.
```

Otherwise, capture `<pr-number>` and `<pr-title>` for the final report.

### 3. Uncommitted changes

Run `git status --short`. If there is any output, stop and warn:

```
WARNING: You have uncommitted or unstaged changes. Stash or commit them before running cleanup.
```

## Cleanup

If all checks pass, run in order. **Stop immediately if any step fails** — do not proceed to subsequent steps. In particular, never run `git branch -D` if `git checkout main` or `git up` failed: the local branch may be the only place those commits still exist.

1. `git checkout main`
2. `git up` (custom alias: `git remote update -p && git merge --ff-only @{u}` — fails loudly if local `main` has diverged)
3. `git branch -D <branch>` (force delete is required because squash-merges rewrite the SHA, so `git branch -d` would refuse)

Report:

```
Cleaned up branch `<branch>` (PR #<pr-number>: <pr-title>). main is now at <short-sha>.
```

## home-manager only: apply the merged config

If `git remote get-url origin` matches `ojhermann/home-manager`, also run `switch` after the cleanup above to apply the newly-merged config to this machine. This step is skipped in every other repo.
