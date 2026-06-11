{ pkgs, lib, ... }:
let
  claudeCode = import ../packages/claude-code.nix {
    inherit lib;
    inherit (pkgs)
      stdenv
      fetchzip
      autoPatchelfHook
      procps
      bubblewrap
      socat
      ;
  };
in
{
  programs.claude-code = {
    enable = true;
    package = claudeCode;

    context = ./claude/CLAUDE.md;

    settings = {
      # Kill the built-in auto-updater. The package is pinned and Nix-managed
      # (updated via `update-claude-code`), and the binary lives in the
      # read-only /nix/store, so the self-updater can only ever fail —
      # surfacing as an "auto-update failed" report in /doctor and on startup.
      # `DISABLE_AUTOUPDATER` stops the update *check* entirely; the
      # `autoUpdates: false` setting alone only blocks installing, so the check
      # still runs and fails.
      env.DISABLE_AUTOUPDATER = "1";

      permissions = {
        allow = [
          "Bash(aws configure:*)"
          "Bash(aws ec2:*)"
          "Bash(curl *)"
          "Bash(gh *)"
          "Bash(git *)"
          "Bash(home-manager *)"
          "Bash(nix *)"
          "Bash(prek *)"
          "Bash(python *)"
          "Bash(tofu *)"
          "Bash(uv *)"
        ];
        deny = [ "Bash(tofu apply*)" ];
      };
    };

    skills."pre-pr" = ./claude/skills/pre-pr/SKILL.md;
    skills."post-pr" = ./claude/skills/post-pr/SKILL.md;
    skills."new-repo" = ./claude/skills/new-repo/SKILL.md;
    skills."standup" = ./claude/skills/standup/SKILL.md;
  };

  home.file.".claude/keybindings.json".source = ./claude/keybindings.json;
}
