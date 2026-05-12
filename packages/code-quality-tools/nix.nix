{ pkgs }:
{
  packages = [
    pkgs.deadnix
    pkgs.flake-checker
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
    {
      id = "flake-checker";
      entry = "flake-checker --fail-mode --no-telemetry";
      files = "^flake\\.(nix|lock)$";
      pass_filenames = false;
    }
  ];
}
