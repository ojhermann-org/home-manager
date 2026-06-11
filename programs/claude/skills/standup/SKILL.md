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
- **Hyperlink each issue ID** to its Linear URL (captured in step 1) using Slack
  link syntax: `<https://linear.app/getlora/issue/LOR-336/...|LOR-336>`. Hyperlink
  PR references to GitHub too: `<https://github.com/getlora/lora/pull/278|#278>`.
- **Mention Otto** in the title with his Slack user ID, not a plain name:
  `*Daily update — <@U0B8HT6RVHC>*` (look it up via the Slack `users_search` tool
  if the ID isn't known).

## 3. Approval gate (mandatory)

Show Otto the fully rendered draft and ask for explicit approval to post,
naming the target channel. Do **not** call any Slack posting tool until he
clearly approves (e.g. "post it", "yes", "send"). If he requests edits, revise
and re-show. If he declines, stop without posting.

## 4. Post to Slack

Once approved, post the message via the Slack MCP posting tool to the agreed
channel (default `#daily-priorities` unless Otto names another).

**Post via Block Kit** (the `blocks` param), not `text`/`content_type`. A single
`section` block with a `mrkdwn` text field renders everything correctly at once —
`*bold*`, `•`, `:emoji:`, `<url|label>` links, `<@USERID>` mentions, and literal
`\n` line breaks. Pass a short `text` value too as the notification fallback.

Do **not** post as `text/markdown`: it collapses the single newlines between `•`
bullets into spaces, putting every bullet on one line. (`text/plain` keeps line
breaks but escapes the `<…>` link/mention syntax — so Block Kit is the only option
that gives links, mentions, and line breaks together.)

Example payload:

```json
[
  {
    "type": "section",
    "text": {
      "type": "mrkdwn",
      "text": "*Daily update — <@U0B8HT6RVHC>*\n\n:white_check_mark: *Yesterday*\n• <https://linear.app/getlora/issue/LOR-336/...|LOR-336> short title — done\n\n:warning: *Blockers*\n• none"
    }
  }
]
```

After posting, confirm with a link or the channel name. If the post fails (e.g.
the bot isn't in the channel, or the token is still the placeholder), report the
error plainly and do not retry blindly. Note: the packaged korotovsky v1.3.0
server has no delete/edit tool, so a posted message can't be fixed in place — get
the format right before posting.
