_:

{
  programs.helix.languages.language = [
    {
      name = "toml";
      auto-format = true;
      formatter = {
        command = "taplo";
        args = [
          "fmt"
          "-"
        ];
      };
    }
  ];
}
