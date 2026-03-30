{ pkgs, ... }:
{
  home.packages = [
    pkgs.awscli2
    pkgs.ssm-session-manager-plugin
  ];
}
