# Slack daily-standup automation — home-manager handoff

Scratch planning doc for a separate home-manager session. Goal: automate a daily
Slack standup **drafted from Linear**, posted **only after I approve it**. Built in
home-manager so the Slack connection is declarative and available to every Claude
Code session/machine — not tied to the `lora` repo.

## Status (updated)

**Phases 2 + 3 are implemented** on branch `feat/slack-standup-mcp` (config builds
clean for `otto@aarch64-darwin`). Locked decisions: **agenix** for secrets,
**korotovsky/slack-mcp-server v1.3.0** (packaged via `buildGoModule`), **bot token
(`xoxb-`)**. The token is injected at runtime by a wrapper script and never touches
`.mcp.json` (verified). Considered and rejected the official Slack connector: it's
OAuth/account-level (not declarative) and may be absent in headless/scheduled runs,
which breaks Phase 4.

**Remaining (yours):**

1. **Phase 1** — create the Slack app + `xoxb-` bot token (scopes below), invite the
   bot to the target channel.
2. Put the real token in place: `agenix -e secrets/slack-bot-token.age` (replaces the
   committed placeholder), then `switch`.
3. **Phase 0** — validate the Linear query/format against real data.
4. **Phase 4** — schedule the daily draft+ping routine; narrow `SLACK_MCP_ADD_MESSAGE_TOOL`
   in `programs/slack-mcp.nix` from `"true"` to the standup channel ID once known.

## Decisions already locked

- **Delivery:** a **Slack MCP server**, managed in home-manager (chosen over a
  repo-local webhook because an MCP gives broader utility — read channels, search,
  DMs — beyond just posting).
- **Message format:** _Yesterday / Today / Blockers_, driven by Linear status
  changes. Example:

  ```
  *Daily update — Otto*

  :white_check_mark: *Yesterday*
  • LOR-333 knip widened — merged (#277)
  • LOR-342 dropped Bedrock SDKs — merged (#278)

  :arrow_forward: *Today*
  • LOR-336 scheme taxonomy — in review (#279)

  :warning: *Blockers*
  • none
  ```

- **Cadence:** a daily **scheduled draft + ping** — a cloud routine drafts at a set
  time and pings me to approve+post (keeps the approval gate, drops the "remember
  to do it"). This is account-level (Claude Code routines), not a home-manager file.
- **Draft source:** Linear — issues assigned to me, active cycle, status changes
  since the last update.

## What's confirmed about the home-manager setup (so the next session moves fast)

- Claude Code is managed by **`programs.claude-code`** (from `nix-community/home-manager`,
  `modules/programs/claude-code.nix`), wired in `programs/claude-code.nix`.
- **Skills** deploy via `skills."<name>" = ./claude/skills/<name>/SKILL.md;` — exactly
  how `pre-pr` / `post-pr` / `new-repo` are done today. (The module also supports
  `agents`, `commands`, and `*Dir` variants.)
- **MCP servers** are a first-class option — **`programs.claude-code.mcpServers`**
  (confirmed, module line ~472). Shape:
  ```nix
  programs.claude-code.mcpServers.slack = {
    type = "stdio";
    command = "...";          # the Slack MCP binary / npx / uvx invocation
    args = [ ... ];
    env = { ... };            # ⚠ written verbatim into generated ~/.claude/.mcp.json
  };
  ```
  **⚠ Secret hazard:** anything in `env` lands in the generated `.mcp.json`. The Slack
  token must **not** be a literal here — inject it at runtime instead (see Secrets).
- **No secrets framework exists yet.** `packages/code-quality-tools/secrets.nix` is
  just the gitleaks hook (secret _scanning_), and `programs/slack.nix` only installs
  the Slack desktop app. This is the gap you flagged wanting to enhance.

## Build plan

| Phase | Owner   | Where        | What                                                                                                                                          | Status  |
| ----- | ------- | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| 0     | me      | lora session | Validate the draft against real Linear data (no setup needed) — I can run this anytime to lock the query + format before plumbing.            | ⬜ todo |
| 1     | **you** | Slack        | Create a Slack app, get a **bot token (`xoxb-`)** + target channel.                                                                           | ⬜ todo |
| 2     | me      | **HM PR**    | Add Slack to `programs.claude-code.mcpServers`; token injected at runtime (not committed).                                                    | ✅ done |
| 3     | me      | **HM PR**    | New `programs/claude/skills/standup/SKILL.md` + register in `claude-code.nix`. Encodes: query Linear → format → approve → post via Slack MCP. | ✅ done |
| 4     | me      | account      | Daily scheduled draft+ping routine.                                                                                                           | ⬜ todo |

(HM PRs follow the repo's branch → PR → `switch` flow.)

## Open decisions

**1. Slack MCP server + token type.** Recommend a **bot token (`xoxb-`)** for reliable
unattended/scheduled posting (browser session tokens expire). Server candidates:

- `@modelcontextprotocol/server-slack` — official-style, simple, `SLACK_BOT_TOKEN` +
  `SLACK_TEAM_ID`, post-focused.
- `korotovsky/slack-mcp-server` — 15 tools, more powerful, **write disabled by default**
  (good safety match), but defaults to `xoxp`/browser tokens; confirm `xoxb` support +
  exact env var names.

Bot scopes to request: **`chat:write`** (required to post) + `channels:read`,
`channels:history`, `users:read`, `search:read` (general utility).

Prefer a Nix-packaged server (or pin the npx/uvx version) so it stays reproducible.

**2. Secrets framework** (the thing you want to discuss — see next section).

**3. Channel + post time** for Phase 4 (e.g. `#standup`, 09:00).

## Secrets framework — options to discuss

The invariant: the token is injected into the **MCP server's process environment at
runtime** and must **never** appear in the committed `.mcp.json` / Nix. Options, roughly
increasing in setup cost:

| Option                   | How                                                                                              | Trade-offs                                                                                      |
| ------------------------ | ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| **Gitignored env file**  | `~/.config/secrets/slack.env` sourced by zsh; MCP inherits the var                               | Trivial; plaintext on disk; not declarative                                                     |
| **macOS Keychain**       | wrapper script does `security find-generic-password`, exports the var, then execs the MCP server | Native, no new deps, encrypted at rest; macOS-only; a bit of wrapper glue                       |
| **sops-nix**             | age/PGP-encrypted secrets committed to the repo, decrypted at activation to a runtime path/env   | The "proper" declarative Nix way; reusable + cross-machine; setup cost (age keys, `.sops.yaml`) |
| **agenix**               | age-encrypted secrets, simpler than sops-nix                                                     | Declarative + reusable; fewer features than sops                                                |
| **1Password CLI (`op`)** | `op read`/`op run` injects at launch                                                             | Great DX if already on 1Password; nothing encrypted-at-rest in the repo; depends on `op` + auth |

Suggested path: **unblock the standup now** with Keychain or an env file, and adopt
**sops-nix** (or agenix) as the reusable framework if you want declarative,
cross-machine secrets — with the Slack token as its first consumer. Once that exists,
Phase 2 just references the managed secret.

## First actions in the home-manager session

1. Decide the secrets approach (above) — it gates how Phase 2 injects the token.
2. Pick + pin the Slack MCP server; figure out the runtime token-injection (wrapper
   script vs `${VAR}` expansion in `.mcp.json`).
3. Implement Phase 2 (mcpServers) + Phase 3 (standup skill) on a branch → PR → `switch`.
4. Back in a normal session: I run Phase 0 to finalize the Linear query/format, then
   wire Phase 4 (scheduled routine).

## References

- Slack MCP server (powerful): https://github.com/korotovsky/slack-mcp-server
- Slack tokens & scopes: https://docs.slack.dev/authentication/tokens/
- HM module: `nix-community/home-manager` → `modules/programs/claude-code.nix`
  (`mcpServers`, `skills`, `agents`, `commands` options)
