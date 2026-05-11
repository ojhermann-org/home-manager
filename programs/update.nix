{ pkgs, ... }:

let
  updateClaudeCode = pkgs.writeShellApplication {
    name = "update-claude-code";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
      pkgs.git
      pkgs.gnused
    ];
    text = builtins.readFile ./shell/scripts/update-claude-code.sh;
  };

  update = pkgs.writeShellApplication {
    name = "update";
    runtimeInputs = [ updateClaudeCode ];
    text = ''
      update-claude-code
      nix flake update
    '';
  };
in
{
  home.packages = [
    updateClaudeCode
    update
  ];
}
