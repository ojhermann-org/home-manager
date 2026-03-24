{ pkgs, ... }:

{
  home.packages = [
    pkgs.docker-compose-language-service
    pkgs.yaml-language-server
  ];

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
