{ pkgs, ... }:
{
  home.packages = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    pkgs.orbstack
  ];
}
