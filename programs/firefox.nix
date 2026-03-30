{ pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  programs.firefox.enable = true;
}
