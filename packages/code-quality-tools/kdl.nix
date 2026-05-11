{ pkgs }:
{
  packages = [
    pkgs.kdlfmt
  ];
  hooks = [
    {
      id = "kdlfmt";
      entry = "kdlfmt format";
      files = "\\.kdl$";
    }
  ];
}
