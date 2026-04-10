{ pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  programs.firefox = {
    enable = true;
    profiles = {
      otto-personal = {
        id = 0;
        isDefault = true;
      };
      jump-box = {
        id = 1;
        settings = {
          "network.proxy.type" = 1;
          "network.proxy.socks" = "localhost";
          "network.proxy.socks_port" = 1080;
          "network.proxy.socks_version" = 5;
          "network.proxy.socks_remote_dns" = true;
        };
      };
    };
  };
}
