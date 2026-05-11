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
  };

  home.file.".claude/keybindings.json".source = ./claude/keybindings.json;
}
