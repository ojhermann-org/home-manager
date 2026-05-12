{ pkgs }:
{
  packages = [ pkgs.gitleaks ];
  hooks = [
    {
      id = "gitleaks";
      entry = "gitleaks git --pre-commit --staged --redact --verbose";
      pass_filenames = false;
    }
  ];
}
