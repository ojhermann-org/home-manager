{ pkgs, ... }:

{
  home.packages = [
    pkgs.pkl
    pkgs.pkl-lsp
  ];

  programs.helix.languages.language = [
    {
      name = "pkl";
      auto-format = true;
      language-servers = [ "pkl-lsp" ];
    }
  ];
}
