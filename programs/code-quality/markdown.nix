{ pkgs, ... }:
{
  home.packages = import ../../packages/code-quality-tools/markdown.nix { inherit pkgs; };
}
