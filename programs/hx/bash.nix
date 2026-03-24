{ pkgs, ... }:

{
  home.packages = [
    pkgs.bash-language-server
    pkgs.shfmt
  ];

  programs.helix.languages.language = [
    {
      name = "bash";
      auto-format = true;
      formatter = {
        command = "shfmt";
      };
    }
  ];
}
