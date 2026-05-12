{ pkgs, ... }:

{
  home.packages = [
    pkgs.bash-language-server
    pkgs.docker-compose-language-service
    pkgs.dockerfile-language-server
    pkgs.jinja-lsp
    pkgs.markdown-oxide
    pkgs.marksman
    pkgs.nil
    pkgs.nixd
    pkgs.terraform-ls
    pkgs.tombi
    pkgs.yaml-language-server
  ];
}
