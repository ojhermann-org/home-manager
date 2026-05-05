{ pkgs, lib, ... }:

let
  gst = import ../packages/gst.nix { inherit pkgs; };

  switchDarwinAarch64 = pkgs.writeShellApplication {
    name = "switch";
    text = ''
      home-manager switch --flake github:ojhermann/home-manager#otto@aarch64-darwin --refresh
    '';
  };

  newsDarwinAarch64 = pkgs.writeShellApplication {
    name = "news";
    text = ''
      home-manager news --flake github:ojhermann/home-manager#otto@aarch64-darwin
    '';
  };

  switchLinuxX86_64 = pkgs.writeShellApplication {
    name = "switch";
    text = ''
      home-manager switch --flake github:ojhermann/home-manager#otto@x86_64-linux --refresh
    '';
  };

  newsLinuxX86_64 = pkgs.writeShellApplication {
    name = "news";
    text = ''
      home-manager news --flake github:ojhermann/home-manager#otto@x86_64-linux
    '';
  };

  switchLinuxAarch64 = pkgs.writeShellApplication {
    name = "switch";
    text = ''
      home-manager switch --flake github:ojhermann/home-manager#otto@aarch64-linux --refresh
    '';
  };

  newsLinuxAarch64 = pkgs.writeShellApplication {
    name = "news";
    text = ''
      home-manager news --flake github:ojhermann/home-manager#otto@aarch64-linux
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

  updateClaudeCode = pkgs.writeShellApplication {
    name = "update-claude-code";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
      pkgs.git
      pkgs.gnused
    ];
    text = builtins.readFile ./shell/scripts/update-claude-code.sh;
  };

  update = pkgs.writeShellApplication {
    name = "update";
    runtimeInputs = [ updateClaudeCode ];
    text = ''
      update-claude-code
      nix flake update
    '';
  };

  commonAliases = {
    ct = "tree -aC --gitignore -I \".terraform|.git\"";
    date = "date +'%Y-%m-%d %H:%M:%S'";
    grep = "grep -i --color=auto";
    gs = "git status -sb";
    ls = "ls --color=auto";
    tree = "tree -aC";
    zj = "zellij";
  };
in
{
  home.sessionPath = [ "$HOME/.local/bin" ];

  home.packages = [
    pkgs.coreutils
    gst
    newPyDir
    newZsh
    newBash
    updateClaudeCode
    update
  ]
  ++ lib.optionals (pkgs.stdenv.hostPlatform.isDarwin && pkgs.stdenv.hostPlatform.isAarch64) [
    switchDarwinAarch64
    newsDarwinAarch64
  ]
  ++ lib.optionals (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86_64) [
    switchLinuxX86_64
    newsLinuxX86_64
  ]
  ++ lib.optionals (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isAarch64) [
    switchLinuxAarch64
    newsLinuxAarch64
  ];

  home.activation.sudoByTouch = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] (builtins.readFile ./shell/scripts/sudo-by-touch.sh)
  );

  programs.zsh = {
    enable = true;
    history = {
      size = 200;
      ignoreDups = true;
    };
    shellAliases = commonAliases;
    initContent =
      (builtins.readFile ./shell/scripts/zsh-init.sh)
      + ''
        compdef ct=tree
      ''
      + lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
        ulimit -Ss 61440
      '';
  };

  programs.bash = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    enable = true;
    historySize = 200;
    historyControl = [ "ignoredups" ];
    shellAliases = commonAliases;
    initExtra = (builtins.readFile ./shell/scripts/bash-init.sh) + ''
      ulimit -Ss 61440
    '';
  };
}
