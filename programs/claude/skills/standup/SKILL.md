Draft a daily standup from Linear and post it to Slack only after Otto approves it.

Use this skill when Otto asks to write, draft, or post his daily standup / daily
update. It reads from the Linear MCP, formats the update, shows it for approval,
and posts via the Slack MCP — **never posting without explicit approval**.

## Prerequisites

- **Linear MCP** tools available (issues, cycles). Used to source the content.
- **Slack MCP** tools available (the `slack` server wired in `programs/slack-mcp.nix`).
  Used only at the final post step.

If either MCP is missing, say so and stop — do not improvise content or post.

## 1. Gather from Linear

Pull Otto's work, scoped tightly:

- Issues **assigned to Otto** in the **active cycle**.
- Determine "since the last update" — default to the last working day (on Monday,
  cover Friday→now). If unsure of the window, ask.
- For each relevant issue capture: identifier (e.g. `LOR-333`), short title,
  current status, and any linked PR number if present in the issue.

Bucket the issues:

- **Yesterday** — issues that **moved to Done / merged / closed** within the window.
- **Today** — issues currently **In Progress** or **In Review**.
- **Blockers** — issues flagged blocked, or with a stated blocker. If none, say "none".

## 2. Format the message

Match this exact shape (Slack mrkdwn), substituting real data:

```
*Daily update — Otto*

:white_check_mark: *Yesterday*
• LOR-333 knip widened — merged (#277)

:arrow_forward: *Today*
• LOR-336 scheme taxonomy — in review (#279)

:warning: *Blockers*
• none
```

Rules:

- One bullet per issue: `<ID> <short title> — <status>` plus `(#PR)` when known.
- Keep titles terse; don't paste full Linear titles verbatim if long.
- Omit a section's bullets only if truly empty — keep the header and write "• none".

## 3. Approval gate (mandatory)

Show Otto the fully rendered draft and ask for explicit approval to post,
naming the target channel. Do **not** call any Slack posting tool until he
clearly approves (e.g. "post it", "yes", "send"). If he requests edits, revise
and re-show. If he declines, stop without posting.

## 4. Post to Slack

Once approved, post the message via the Slack MCP posting tool to the agreed
channel (default `#standup` unless Otto names another). After posting, confirm
with a link or the channel name. If the post fails (e.g. the bot isn't in the
channel, or the token is still the placeholder), report the error plainly and
do not retry blindly.
