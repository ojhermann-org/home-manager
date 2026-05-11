{ pkgs }:
{
  packages = [
    pkgs.deadnix
    pkgs.nixfmt
    pkgs.statix
  ];
  hooks = [
    {
      id = "nixfmt";
      entry = "nixfmt";
      files = "\\.nix$";
    }
    {
      id = "statix";
      entry = "statix fix";
      pass_filenames = false;
    }
    {
      id = "deadnix";
      entry = "deadnix --edit";
      files = "\\.nix$";
    }
  ];
}
