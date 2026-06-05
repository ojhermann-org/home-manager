{ pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  home.packages = [ pkgs.slack ];
}
