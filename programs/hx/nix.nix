{ pkgs, ... }:

{
  home.packages = [
    pkgs.nil
    pkgs.nixd
    pkgs.nixfmt
    pkgs.statix
    pkgs.deadnix
  ];

  programs.helix.languages.language = [
    {
      name = "nix";
      auto-format = true;
      formatter = {
        command = "nixfmt";
      };
    }
  ];
}
