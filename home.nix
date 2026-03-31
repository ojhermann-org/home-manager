{
  config,
  pkgs,
  lib,
  ...
}:

let
  username = "otto";
  homeDirectoryApple = "/Users/${username}";
  homeDirectoryLinux = "/home/${username}";
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
    inherit username;
    homeDirectory =
      if pkgs.stdenv.hostPlatform.isDarwin then homeDirectoryApple else homeDirectoryLinux;
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.11"; # Please read the comment before changing.
    packages = [ ];
    file = { };
    sessionVariables = {
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
