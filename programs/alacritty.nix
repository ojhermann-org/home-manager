{ pkgs, ... }:

{
  home.packages = [ pkgs.alacritty ];

  programs.alacritty = {
    enable = true;
    settings = {
      mouse.hide_when_typing = true;

      window.startup_mode = "Fullscreen";
    };
  };
}
