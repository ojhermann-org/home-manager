{ pkgs, ... }:
{
  home.packages = [
    pkgs.ansible-language-server
    pkgs.yaml-language-server
  ];
}
