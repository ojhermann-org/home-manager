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
    {
      id = "shfmt";
      entry = "shfmt -w -i 2";
      files = "\\.sh$";
    }
  ];
}
