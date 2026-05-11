{ pkgs }:
{
  packages = [
    pkgs.prettier
  ];
  hooks = [
    {
      id = "prettier";
      entry = "prettier --write";
      files = "\\.md$";
    }
  ];
}
