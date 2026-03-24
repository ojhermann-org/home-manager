{ pkgs, lib, ... }:

let
  gst      = import ../packages/gst.nix       { inherit pkgs; };
  watchDir = import ../packages/watch-dir.nix { inherit pkgs gst; };

  switchDarwinAarch64 = pkgs.writeShellApplication {
    name = "switch";
    text = ''
      home-manager switch --flake github:ojhermann/home-manager#otto@aarch64-darwin --refresh
    '';
  };

  switchLinuxX86_64 = pkgs.writeShellApplication {
    name = "switch";
    text = ''
      home-manager switch --flake github:ojhermann/home-manager#otto@x86_64-linux --refresh
    '';
  };

  switchLinuxAarch64 = pkgs.writeShellApplication {
    name = "switch";
    text = ''
      home-manager switch --flake github:ojhermann/home-manager#otto@aarch64-linux --refresh
    '';
  };

  newPyDir = pkgs.writeShellApplication {
    name = "new-py-dir";
    runtimeInputs = [ pkgs.coreutils ];
    text = builtins.readFile ./shell/scripts/new-py-dir.sh;
  };
  newZsh = pkgs.writeShellApplication {
    name = "new-zsh";
    runtimeInputs = [ pkgs.coreutils ];
    text = builtins.readFile ./shell/scripts/new-zsh.sh;
  };
  newBash = pkgs.writeShellApplication {
    name = "new-bash";
    runtimeInputs = [ pkgs.coreutils ];
    text = builtins.readFile ./shell/scripts/new-bash.sh;
  };

  commonAliases = {
    date = "date +'%Y-%m-%d %H:%M:%S'";
    grep = "grep -i --color=auto";
    gs = "git status -sb";
    ls = "ls --color=auto";
    tree = "tree -aC";
    zj = "zellij";
  };
in
{
  home.packages =
    [ pkgs.coreutils gst newPyDir newZsh newBash watchDir ]
    ++ lib.optional (pkgs.stdenv.hostPlatform.isDarwin && pkgs.stdenv.hostPlatform.isAarch64) switchDarwinAarch64
    ++ lib.optional (pkgs.stdenv.hostPlatform.isLinux  && pkgs.stdenv.hostPlatform.isx86_64)  switchLinuxX86_64
    ++ lib.optional (pkgs.stdenv.hostPlatform.isLinux  && pkgs.stdenv.hostPlatform.isAarch64) switchLinuxAarch64;

  home.activation.sudoByTouch = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] (builtins.readFile ./shell/scripts/sudo-by-touch.sh)
  );

  programs.zsh = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    history = {
      size = 200;
      ignoreDups = true;
    };
    shellAliases = commonAliases;
    initContent = builtins.readFile ./shell/scripts/zsh-init.sh;
  };

  programs.bash = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    enable = true;
    historySize = 200;
    historyControl = [ "ignoredups" ];
    shellAliases = commonAliases;
    initExtra = builtins.readFile ./shell/scripts/bash-init.sh;
  };
}
