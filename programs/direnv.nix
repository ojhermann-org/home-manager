_:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      whitelist = {
        prefix = [ "/Users/otto/Documents" "/home/otto/Documents" ];
      };
    };
  };
}
