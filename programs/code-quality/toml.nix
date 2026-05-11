{ pkgs, ... }:
{
  home.packages = import ../../packages/code-quality-tools/toml.nix { inherit pkgs; };
}
