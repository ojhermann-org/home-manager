{ pkgs, ... }:

{
  home.packages = [
    pkgs.tlaplus18
    pkgs.tlafmt
  ];
}
