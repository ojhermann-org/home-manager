_:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "default";
      editor = {
        true-color = true;
        file-picker.hidden = false;
        lsp.display-inlay-hints = true;
      };
    };
    languages = {
      language = [
        {
          name = "bash";
          auto-format = true;
          formatter = {
            command = "shfmt";
          };
        }
        {
          name = "docker-compose";
          auto-format = true;
          formatter = {
            command = "yamlfmt";
            args = [ "-" ];
          };
        }
        {
          name = "hcl";
          auto-format = true;
          language-servers = [ "terraform-ls" ];
          formatter = {
            command = "tofu";
            args = [
              "fmt"
              "-"
            ];
          };
        }
        {
          name = "kdl";
          auto-format = true;
          formatter = {
            command = "kdlfmt";
            args = [
              "format"
              "--stdin"
            ];
          };
        }
        {
          name = "markdown";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "markdown"
            ];
          };
        }
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "nixfmt";
          };
        }
        {
          name = "tlaplus";
          auto-format = true;
        }
        {
          name = "toml";
          auto-format = true;
          formatter = {
            command = "taplo";
            args = [
              "fmt"
              "-"
            ];
          };
        }
        {
          name = "yaml";
          auto-format = true;
          formatter = {
            command = "yamlfmt";
            args = [ "-" ];
          };
        }
      ];
    };
  };
}
