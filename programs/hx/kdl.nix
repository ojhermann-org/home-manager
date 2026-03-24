{ pkgs, ... }:

{
  home.packages = [
    pkgs.kdlfmt
  ];

  programs.helix.languages.language = [
    {
      name = "kdl";
      auto-format = true;
      formatter = {
        command = "kdlfmt";
        args = [
          "format"
          "--stdin"
        ];
      };
    }
  ];
}
