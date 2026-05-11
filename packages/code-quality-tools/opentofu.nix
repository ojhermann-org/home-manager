{ pkgs }:
{
  packages = [
    pkgs.terraform-docs
    pkgs.tflint
  ];
  hooks = [
    {
      id = "terraform-docs";
      entry = "terraform-docs markdown table . --recursive --output-file README.md --output-mode inject --output-check";
      files = "\\.tf$";
      pass_filenames = false;
    }
  ];
}
