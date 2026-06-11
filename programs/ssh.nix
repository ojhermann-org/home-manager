{ lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      "github.com" = {
        HostName = "github.com";
        IdentityFile = "~/.ssh/id_ed25519";
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
      };
    };
  };

  # Isolated ssh config that offers ONLY the getlora key (~/.ssh/lora) for
  # github.com. Selected via core.sshCommand in programs/git.nix, so work in any
  # repo under ~/lora authenticates as the getlora GitHub account instead of the
  # default id_ed25519. Kept as a separate `-F` config rather than a Host alias
  # so the git remote stays github.com and the gh CLI still resolves it.
  home.file.".ssh/config-getlora" = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    text = ''
      Host github.com
        HostName github.com
        User git
        IdentityFile ~/.ssh/lora
        IdentitiesOnly yes
        AddKeysToAgent yes
        UseKeychain yes
    '';
  };
}
