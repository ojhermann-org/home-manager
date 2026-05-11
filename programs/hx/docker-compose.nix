_:

{
  programs.helix.languages.language = [
    {
      name = "docker-compose";
      auto-format = true;
      formatter = {
        command = "yamlfmt";
        args = [ "-" ];
      };
    }
  ];
}
