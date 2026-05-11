{ pkgs, ... }:
{
  home.packages = (import ../../packages/code-quality-tools/nix.nix { inherit pkgs; }).packages;
}
