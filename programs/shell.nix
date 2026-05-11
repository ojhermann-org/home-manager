{ pkgs, lib, ... }:

let
  mkSystemCommands = system: {
    switch = pkgs.writeShellApplication {
      name = "switch";
      text = ''
        home-manager switch --flake "github:ojhermann/home-manager#$USER@${system}" --refresh
      '';
    };
    news = pkgs.writeShellApplication {
      name = "news";
      text = ''
        home-manager news --flake "github:ojhermann/home-manager#$USER@${system}"
      '';
    };
  };

  systemCommands = mkSystemCommands pkgs.stdenv.hostPlatform.system;

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
    systemCommands.switch
    systemCommands.news
  ];

  home.activation.sudoByTouch = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] (builtins.readFile ./shell/scripts/sudo-by-touch.sh)
  );

  programs.zsh = {
    enable = true;
    history = {
      size = 200;
      ignoreAllDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
      extended = true;
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
    historyControl = [
      "erasedups"
      "ignorespace"
    ];
    shellAliases = commonAliases;
    initExtra = (builtins.readFile ./shell/scripts/bash-init.sh) + ''
      ulimit -Ss 61440
    '';
  };
}
