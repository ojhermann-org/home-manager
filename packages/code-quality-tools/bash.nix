{ pkgs }:
{
  packages = [
    pkgs.shellcheck
    pkgs.shfmt
  ];
  hooks = [
    {
      id = "shellcheck";
      entry = "shellcheck";
      files = "\\.sh$";
    }
  ];
}
