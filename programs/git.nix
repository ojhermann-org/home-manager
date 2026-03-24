{ pkgs, ... }:
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
  };
}
