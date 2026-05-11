_:

{
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
