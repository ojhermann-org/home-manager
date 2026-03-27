{ pkgs, ... }:

{
  home.packages = [
    pkgs.terraform-ls
  ];

  programs.helix.languages.language = [
    {
      name = "hcl";
      auto-format = true;
      language-servers = [ "terraform-ls" ];
      formatter = {
        command = "tofu";
        args = [
          "fmt"
          "-"
        ];
      };
    }
  ];
}
