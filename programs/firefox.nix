{ pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  programs.firefox = {
    enable = true;
    profiles = {
      otto-personal = {
        id = 0;
        isDefault = true;
      };
    };
  };
}
