{ pkgs, ... }:
{
  home.packages = (import ../../packages/code-quality-tools/kdl.nix { inherit pkgs; }).packages;
}
