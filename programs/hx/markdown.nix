{ pkgs, ... }:

{
  home.packages = [
    pkgs.markdown-oxide
    pkgs.marksman
    pkgs.prettier
  ];

  programs.helix.languages.language = [
    {
      name = "markdown";
      auto-format = true;
      formatter = {
        command = "prettier";
        args = [
          "--parser"
          "markdown"
        ];
      };
    }
  ];
}
