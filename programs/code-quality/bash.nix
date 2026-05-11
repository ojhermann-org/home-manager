{ pkgs, ... }:
{
  home.packages = import ../../packages/code-quality-tools/bash.nix { inherit pkgs; };
}
