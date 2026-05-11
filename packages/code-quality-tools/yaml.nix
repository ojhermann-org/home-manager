{ pkgs }:
{
  packages = [
    pkgs.yamlfmt
  ];
  hooks = [
    {
      id = "yamlfmt";
      entry = "yamlfmt -formatter retain_line_breaks=true";
      files = "\\.ya?ml$";
    }
  ];
}
