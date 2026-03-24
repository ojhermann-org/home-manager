{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      copy_command = if pkgs.stdenv.hostPlatform.isDarwin then "pbcopy" else "xclip -selection clipboard";
      default_layout = "basic";
      default_shell = "zsh";
      show_start_up_tips = false;
      theme = "kanagawa";
    };
  };

  xdg.configFile."zellij/layouts".source = ./zellij/layouts;
}
