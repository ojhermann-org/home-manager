# `gh` getlora identity — home-manager

Goal: make the **`gh` CLI** act as the **getlora work account** (the "otto-lora"
profile) whenever I'm inside `~/lora`, the same way git already does — so
`gh pr`, `gh repo`, `gh pr checkout`, etc. work against `getlora/*` private
repos. The token lives in **agenix**, consistent with the rest of my secrets.

**Status:** the declarative side is **implemented** (branch
`feat/gh-getlora-identity`) — see [The design](#the-design-implemented) below.
All that remains is Otto's one-time token steps in
[Otto's manual actions](#ottos-manual-actions-cant-be-declarative).

## The problem (root cause)

In any `~/lora` repo, `gh repo view getlora/lora-ios` and `gh pr list` fail with
`Could not resolve to a Repository` / HTTP 404. Diagnosed from a `lora` session:

| Check                                  | Result                                                      |
| -------------------------------------- | ----------------------------------------------------------- |
| `git fetch` in `~/lora/lora-ios`       | ✅ works (authenticates as the getlora account — see below) |
| `gh api orgs/getlora`                  | ✅ org is visible                                           |
| `gh repo list getlora`                 | ⚠️ **empty** — token sees zero repos in the org             |
| `gh api repos/getlora/lora-ios`        | ❌ 404                                                      |
| `gh api user/memberships/orgs/getlora` | ❌ 404 — token doesn't see itself as a member               |

This is the classic signature of a **SAML-SSO / wrong-identity gap**: `gh` is
using the single `ojhermann` token in `~/.config/gh/hosts.yml`, which is **not**
authorized for `getlora`. GitHub returns 404 (not 403) for unauthorized tokens,
so it looks like "repo not found."

## What's already in place (and why git works but gh doesn't)

The getlora work identity is **already fully wired for git + ssh**, scoped to
`~/lora/`:

- **`programs/git.nix`** — an `includes` entry with `condition = "gitdir:~/lora/"`
  overrides `user.name = "otto"`, `user.email = "otto@getlora.com"`, and sets
  `core.sshCommand = "ssh -F ~/.ssh/config-getlora"`.
- **`programs/ssh.nix`** — `~/.ssh/config-getlora` is an isolated ssh config that
  offers **only** `~/.ssh/lora` (the getlora account's key) for `github.com`,
  with `IdentitiesOnly yes`. Kept as a separate `-F` file (not a `Host` alias) so
  the remote stays `github.com` and `gh` can still resolve it.

So under `~/lora`, **git** already authenticates and commits as the getlora
account. The earlier "Hi ojhermann" from a bare `ssh -T github.com` was a red
herring — a plain `ssh` call ignores git's `core.sshCommand` and falls back to
the default `~/.ssh/id_ed25519` (ojhermann). git itself uses `~/.ssh/lora`.

**`gh` is the only consumer not switched.** It honors neither `gitdir` includes
nor `core.sshCommand` — it reads `~/.config/gh/hosts.yml` (single `ojhermann`
account, `programs/gh.nix`) regardless of directory. That mismatch is the whole
bug: commits go out as `otto@getlora.com` while the `gh` API acts as `ojhermann`.

## The design (implemented)

Mirror the existing pattern: a **directory-scoped getlora identity for `gh`**,
fed a token from **agenix**, applied only under `~/lora`.

`gh` honors the `GH_TOKEN` env var above everything else (keyring, hosts.yml) —
no `gh auth login` or second `GH_CONFIG_DIR` needed. So:

1. **Store the getlora `gh` token as an agenix secret** — e.g.
   `secrets/gh-getlora-token.age`, recipient = the same `otto` SSH pubkey already
   in `secrets/secrets.nix`, decrypted at activation via `~/.ssh/id_ed25519`
   (already in `age.identityPaths`). The decryption identity being `id_ed25519`
   is fine — it only gates _who can decrypt the file_, unrelated to which GitHub
   account the token authenticates as.

2. **Inject it into `gh` only inside `~/lora`, only into gh's own process** — a
   thin `gh` shell function, mirroring the slack-mcp "secret never enters the
   broad env, only the consumer's process" invariant:

   ```sh
   gh() {
     if [[ "$PWD/" == "$HOME"/lora/* ]]; then
       GH_TOKEN="$(cat "<agenix path>")" command gh "$@"
     else
       command gh "$@"
     fi
   }
   ```

   Prefer this over `export GH_TOKEN` in a `chpwd` hook: the token only enters
   gh's process when gh is actually invoked, never the ambient shell env that
   every other `~/lora` process could read.

### Where it lives in the repo (what changed)

- **`secrets/secrets.nix`** — added `"gh-getlora-token.age".publicKeys = [ otto ];`
- **`programs/agenix.nix`** — added
  `age.secrets."gh-getlora-token".file = ../secrets/gh-getlora-token.age;`
  inside the existing `isDarwin` block.
- **`programs/shell.nix`** — added the `gh` function to zsh `initContent` as an
  **interpolated** Darwin-gated string (not the static `shell/scripts/zsh-init.sh`,
  which is `readFile`'d and can't see Nix values) so
  `${config.age.secrets."gh-getlora-token".path}` is substituted in. The argset
  gained `config`. The generated `.zshrc` resolves the path to
  `$(getconf DARWIN_USER_TEMP_DIR)/agenix/gh-getlora-token`, command-substituted
  at runtime (same mechanism as `programs/slack-mcp.nix`).
- **`secrets/gh-getlora-token.age`** — committed **placeholder** (real value
  pending Otto's `agenix -e`, below). The Darwin activation package builds and
  the round-trip decrypt is verified.

## Decisions (locked)

1. **Token + account — Otto's manual step, doesn't change the Nix.** "otto-lora"
   is assumed to be a **separate GitHub account** holding getlora access (the
   separate `~/.ssh/lora` key + `otto@getlora.com` email imply a deliberately
   separate identity). Mint the PAT while logged into that account: prefer a
   **fine-grained PAT** scoped to the `getlora` org's repos (Contents: read,
   Pull requests: read/write, Metadata: read; add Workflows if needed), or a
   **classic PAT** (`repo`, `read:org`, `workflow`) **SSO-authorized for
   `getlora`**. Token type is a pasted value — it does not affect a line of code.
   The account's GitHub **login is `otto-lora`** (confirmed via `gh api user`);
   the `user.name = "otto"` in the `programs/git.nix` getlora include is only the
   commit-author display name, not the GitHub username.
2. **Function vs. `chpwd` export → wrapper function.** Token enters gh's process
   only when gh is invoked, never the ambient `~/lora` shell env.
3. **Cross-platform → Darwin-only**, matching agenix and the git/ssh getlora
   setup. Generalizing means moving agenix off its Darwin gate — out of scope.

## Otto's manual actions (can't be declarative)

1. Create/confirm the getlora `gh` token (browser login to the otto-lora account →
   mint PAT → SSO-authorize for `getlora` if classic). This is the secret value.
2. `cd secrets && agenix -e gh-getlora-token.age` → paste the token → save.
   (Run from `secrets/`, where `secrets.nix` lives — `agenix` resolves both the
   rules file and the key relative to the current directory, so the repo-root
   form `agenix -e secrets/gh-getlora-token.age` fails with "secrets.nix does not
   exist".)
3. `switch`, then verify from `~/lora/lora-ios`:
   `gh repo view getlora/lora-ios` and `gh pr list` should now resolve.

## Remaining work

1. **Done:** declarative implementation on `feat/gh-getlora-identity` (secrets
   rule + `agenix.nix` secret + the `gh` function in `shell.nix` `initContent`,
   placeholder `.age`). Builds clean; decrypt round-trip verified. → open PR,
   merge, `switch` (per the repo's branch→PR flow).
2. **Otto:** the manual token steps below (mint PAT → `agenix -e` → `switch`).
3. **Hand back:** re-run the probe table above from a `lora` session to confirm
   green, then continue the original task (reviewing the
   `anu/ios-push-notification-contract` PR that kicked this off).

## References

- Existing parallel setup: `programs/git.nix` (`gitdir:~/lora/` include),
  `programs/ssh.nix` (`~/.ssh/config-getlora`).
- Runtime secret-injection pattern to copy: `programs/slack-mcp.nix` +
  `programs/agenix.nix` (`config.age.secrets.<name>.path`, Darwin temp-dir path).
- `gh` auth precedence: `GH_TOKEN` / `GITHUB_TOKEN` override keyring + hosts.yml.
