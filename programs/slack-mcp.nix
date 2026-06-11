{
  config,
  pkgs,
  lib,
  ...
}:

# Slack MCP server for Claude Code, fed a bot token at runtime via agenix.
#
# Secret-handling invariant: the token must NEVER appear in the generated
# ~/.claude/.mcp.json. We achieve that by pointing the MCP server's `command`
# at a wrapper that reads the decrypted token from its agenix path and exports
# it into the server's own process environment — so `.mcp.json` only ever
# contains the wrapper's store path, never the secret.
#
# Darwin-only: matches programs/agenix.nix (which only defines the secret on
# Darwin) and programs/slack.nix (Slack desktop app).
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
  let
    slack-mcp-server = pkgs.callPackage ../packages/slack-mcp-server.nix { };

    # agenix decrypts the token to this path at activation. On Darwin the
    # string embeds a `$(getconf …)` command substitution, which the shell
    # below expands at runtime (bash command-substitutes inside double quotes).
    tokenPath = config.age.secrets."slack-bot-token".path;

    # Posting guard, independent of the skill's approval gate. "true" allows the
    # bot to post — but a bot token can only post to channels it's been invited
    # to, so workspace membership is the real boundary. Narrow this to a single
    # channel ID (e.g. "C0123ABCD") in Phase 4 once the standup channel exists.
    postChannels = "true";

    slack-mcp = pkgs.writeShellApplication {
      name = "slack-mcp";
      runtimeInputs = [ slack-mcp-server ];
      text = ''
        SLACK_MCP_XOXB_TOKEN="$(cat "${tokenPath}")"
        export SLACK_MCP_XOXB_TOKEN
        export SLACK_MCP_ADD_MESSAGE_TOOL="${postChannels}"
        exec slack-mcp-server --transport stdio "$@"
      '';
    };
  in
  {
    programs.claude-code.mcpServers.slack = {
      type = "stdio";
      command = lib.getExe slack-mcp;
    };
  }
)
