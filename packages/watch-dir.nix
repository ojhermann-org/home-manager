{ pkgs, gst }:

pkgs.writeShellApplication {
  name = "watch-dir";
  runtimeInputs = [ pkgs.git pkgs.watchexec gst ];
  text = ''
    if git rev-parse --git-dir >/dev/null 2>&1; then
      git_dir=$(git rev-parse --absolute-git-dir)
      watchexec -c --watch "." --watch "$git_dir/index" --watch "$git_dir/HEAD" --no-vcs-ignore -i "$git_dir/objects/**" -i "$git_dir/logs/**" -- ${gst}/bin/gst
    else
      watchexec -c --watch "." -- ${gst}/bin/gst
    fi
  '';
}
