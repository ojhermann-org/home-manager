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
  };
}
