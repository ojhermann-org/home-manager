{ pkgs }:
{
  packages = [
    pkgs.terraform-docs
    pkgs.tflint
  ];
  hooks = [ ];
}
