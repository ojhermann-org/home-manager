{ pkgs, ... }:

let
  inherit (pkgs) lib;

  toolsDir = ../packages/code-quality-tools;
  toolFiles = builtins.filter (f: lib.hasSuffix ".nix" f) (
    lib.filesystem.listFilesRecursive toolsDir
  );
in
{
  home.packages = builtins.concatMap (f: (import f { inherit pkgs; }).packages) toolFiles;
}
