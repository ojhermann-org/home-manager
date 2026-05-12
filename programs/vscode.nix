{ pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        leanprover.lean4
        jnoortheen.nix-ide
        mkhl.direnv
        eamodio.gitlens
      ];
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
    };
  };
}
