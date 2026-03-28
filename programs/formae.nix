{ pkgs, ... }:

let
  formae = import ../packages/formae.nix { inherit pkgs; };
in
{
  home.packages = [
    formae
  ];
}
