{ pkgs }:

pkgs.writeShellApplication {
  name = "gst";
  runtimeInputs = [ pkgs.git pkgs.tree ];
  text = ''
    if git rev-parse --git-dir >/dev/null 2>&1; then
      git status -sb && tree -aC -I '.git' --gitignore
    else
      tree -aC
    fi
  '';
}
