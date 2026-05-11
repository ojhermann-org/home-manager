_:

{
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
