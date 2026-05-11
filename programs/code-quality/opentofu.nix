{ pkgs, ... }:
{
  home.packages = (import ../../packages/code-quality-tools/opentofu.nix { inherit pkgs; }).packages;
}
