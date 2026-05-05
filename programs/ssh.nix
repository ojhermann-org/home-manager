{ lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          AddKeysToAgent = "yes";
          UseKeychain = "yes";
        };
      };
    };
  };
}
