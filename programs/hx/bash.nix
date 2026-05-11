_:

{
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
