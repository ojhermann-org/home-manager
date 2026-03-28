{ pkgs, lib, ... }:

let
  formae = import ../packages/formae.nix { inherit pkgs; };
  supported =
    pkgs.stdenv.hostPlatform.system == "aarch64-darwin"
    || pkgs.stdenv.hostPlatform.system == "aarch64-linux";
in
lib.mkIf supported {
  home.packages = [
    formae
  ];
}
