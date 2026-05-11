_:

{
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
