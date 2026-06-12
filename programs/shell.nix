{
  config,
  pkgs,
  lib,
  ...
}:

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
    profileExtra = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
    initContent =
      (builtins.readFile ./shell/scripts/zsh-init.sh)
      + ''
        compdef ct=tree
      ''
      # getlora `gh` identity, scoped to ~/lora — the gh-side mirror of the
      # gitdir include in programs/git.nix. `gh` honors neither git's `gitdir`
      # includes nor `core.sshCommand`; it reads ~/.config/gh/hosts.yml (the
      # ojhermann account) regardless of directory. GH_TOKEN overrides that, so
      # under ~/lora we feed gh the getlora PAT from agenix — but only into gh's
      # own process (not the ambient shell env), mirroring the slack-mcp wrapper
      # invariant. The agenix path embeds a `$(getconf …)` substitution the shell
      # expands at runtime (same mechanism as programs/slack-mcp.nix).
      + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        gh() {
          if [[ "$PWD/" == "$HOME"/lora/* ]]; then
            GH_TOKEN="$(cat "${config.age.secrets."gh-getlora-token".path}")" command gh "$@"
          else
            command gh "$@"
          fi
        }
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
