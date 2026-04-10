{ pkgs, lib, ... }:
let
  claudeCode = import ../packages/claude-code.nix {
    inherit lib;
    inherit (pkgs)
      stdenv
      fetchzip
      makeWrapper
      nodejs
      procps
      bubblewrap
      socat
      ;
  };
in
{
  home.packages = [ claudeCode ];

  home.file.".claude/CLAUDE.md".source = ./claude/CLAUDE.md;
  home.file.".claude/keybindings.json".source = ./claude/keybindings.json;
  home.file.".claude/settings.json".source = ./claude/settings.json;
  home.file.".claude/commands/pre-pr.md".source = ./claude/commands/pre-pr.md;
}
