{ pkgs, ... }:
{
  home.packages = [
    pkgs.markdown-oxide
    pkgs.marksman
  ];
}
