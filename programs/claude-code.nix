{ pkgs, ... }:
{
  # claude-code-bin is a pre-built Darwin binary; Linux uses the npm-built package.
  home.packages = [
    (if pkgs.stdenv.hostPlatform.isDarwin then pkgs.claude-code-bin else pkgs.claude-code)
  ];

  home.file.".claude/CLAUDE.md".source = ./claude/CLAUDE.md;
  home.file.".claude/settings.json".source = ./claude/settings.json;
}
