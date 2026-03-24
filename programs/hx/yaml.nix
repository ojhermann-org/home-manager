{ pkgs, ... }:

{
  home.packages = [
    pkgs.yamlfmt
    pkgs.ansible-language-server
  ];

  programs.helix.languages.language = [
    {
      name = "yaml";
      auto-format = true;
      formatter = {
        command = "yamlfmt";
        args = [ "-" ];
      };
    }
  ];
}
