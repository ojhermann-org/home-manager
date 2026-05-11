{ pkgs, ... }:
{
  home.packages = import ../../packages/code-quality-tools/yaml.nix { inherit pkgs; };
}
