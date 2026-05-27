{
  config,
  pkgs,
  lib,
  ...
}:

let
  importAllNixFiles =
    path:
    let
      files = lib.filesystem.listFilesRecursive path;
      nixFiles = lib.lists.filter (file: lib.hasSuffix ".nix" file) files;
    in
    lib.lists.map import nixFiles;
in
{
  nixpkgs.config.allowUnfree = true;

  imports = importAllNixFiles ./programs;

  home = {
    username = "otto";
    homeDirectory =
      if pkgs.stdenv.hostPlatform.isDarwin then
        "/Users/${config.home.username}"
      else
        "/home/${config.home.username}";
    stateVersion = "25.11";
    packages = [ ];
    file = { };
    sessionVariables = {
      COLORTERM = "truecolor";
      EDITOR = "hx";
      VISUAL = config.home.sessionVariables.EDITOR;
    };
  };

  programs.home-manager.enable = true;

  manual = {
    manpages.enable = false;
    html.enable = false;
    json.enable = false;
  };
}
