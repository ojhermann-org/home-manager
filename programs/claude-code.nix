{ pkgs, ... }:
{
  home.packages = [ pkgs.claude-code-bin ];

  home.file.".claude/CLAUDE.md".source = ./claude/CLAUDE.md;
  home.file.".claude/settings.json".source = ./claude/settings.json;
}
