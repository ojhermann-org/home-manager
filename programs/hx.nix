{ ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "default";
      editor.true-color = true;
      editor.file-picker.hidden = false;
      editor.lsp.display-inlay-hints = true;
    };
  };
}
