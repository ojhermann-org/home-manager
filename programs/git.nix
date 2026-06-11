{ lib, pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Otto Hermann";
      user.email = "ojhermann@gmail.com";
      alias = {
        up = "!git remote update -p; git merge --ff-only @{u}";
      };
      init.defaultBranch = "main";
      pull.ff = "only";
      push.autoSetupRemote = true;
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      # getlora work identity, scoped to every repo under ~/lora: the include
      # file overrides the commit email and points git at the isolated ssh config
      # (programs/ssh.nix) so pushes authenticate as the getlora GitHub account
      # rather than ojhermann.
      includeIf."gitdir:~/lora/".path = "~/.config/git/includes/getlora.inc";
    };
  };

  xdg.configFile."git/includes/getlora.inc" = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    text = ''
      [user]
        name = otto
        email = otto@getlora.com
      [core]
        sshCommand = ssh -F ~/.ssh/config-getlora
    '';
  };
}
