{ pkgs }:
{
  packages = [
    pkgs.taplo
  ];
  hooks = [
    {
      id = "taplo";
      entry = "taplo format";
      files = "\\.toml$";
      exclude = "^prek\\.toml$";
    }
  ];
}
