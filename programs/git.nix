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
    };

    # getlora work identity, scoped to every repo under ~/lora: the include
    # overrides the commit email and points git at the isolated ssh config
    # (programs/ssh.nix) so pushes authenticate as the getlora GitHub account
    # rather than ojhermann. Declared via `includes` (not an `includeIf` inside
    # `settings`) so home-manager appends it *after* the base config — git reads
    # config top-to-bottom and a later assignment wins, so the include must be
    # evaluated last to override the base user.email for ~/lora repos.
    includes = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      {
        condition = "gitdir:~/lora/";
        contents = {
          user = {
            name = "otto";
            email = "otto@getlora.com";
          };
          core.sshCommand = "ssh -F ~/.ssh/config-getlora";
        };
      }
    ];
  };
}
