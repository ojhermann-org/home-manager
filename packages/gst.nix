{ pkgs }:

pkgs.writeShellApplication {
  name = "gst";
  runtimeInputs = [
    pkgs.git
    pkgs.tree
  ];
  text = ''
    if git rev-parse --git-dir >/dev/null 2>&1; then
      git status -sb; { git ls-files; git ls-files --others --exclude-standard; } | sort -u | tree -C --fromfile .
    else
      tree -aC
    fi
  '';
}
