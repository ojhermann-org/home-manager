{
  config,
  pkgs,
  lib,
  agenixPackage,
  ...
}:

# agenix: declarative, age-encrypted secrets. The encrypted `.age` files live in
# `secrets/` (committed); they are decrypted at home-manager activation to a
# user-only runtime path (on Darwin: `$(getconf DARWIN_USER_TEMP_DIR)/agenix/<name>`).
# The plaintext secret never enters the Nix store or git.
#
# Currently Darwin-only because its sole consumer (the Slack MCP server) is
# Darwin-only. Drop the `mkIf` when a Linux secret appears.
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  # The `agenix` CLI for creating/editing secrets (`agenix -e secrets/<name>.age`).
  home.packages = [ agenixPackage ];

  # Private keys agenix tries when decrypting at activation.
  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];

  # Slack bot token (xoxb-) for the MCP server. Populate the real value with:
  #   cd secrets && agenix -e slack-bot-token.age
  # (run from secrets/, where secrets.nix lives — agenix resolves the rules file
  # and the key relative to CWD). The committed file is a placeholder until then.
  age.secrets."slack-bot-token".file = ../secrets/slack-bot-token.age;

  # getlora `gh` token (a PAT for the otto-lora work account). Injected into `gh`
  # only inside ~/lora via the wrapper function in programs/shell.nix, so the
  # token authenticates getlora API calls without touching ~/.config/gh/hosts.yml
  # (which stays the ojhermann account). Populate the real value with:
  #   cd secrets && agenix -e gh-getlora-token.age
  # (run from secrets/, where secrets.nix lives — agenix resolves the rules file
  # and the key relative to CWD). The committed file is a placeholder until then.
  age.secrets."gh-getlora-token".file = ../secrets/gh-getlora-token.age;

  # Work around an upstream agenix bug on Darwin. The `activate-agenix` launchd
  # agent (modules/age-home.nix) sets `KeepAlive.Crashed = false`, which tells
  # launchd to relaunch the job after every *non-crash* exit. But the mount
  # script is a one-shot that exits 0 on success, so launchd respawns it forever
  # at its ~10s throttle — re-decrypting every secret and flipping the `agenix`
  # symlink (and `rm -rf`-ing the previous generation) on a loop. Any consumer
  # that reads a secret during a swap window gets a missing/empty file; this is
  # what intermittently broke the Slack MCP server (empty token -> auth failure
  # -> Claude never registers its tools).
  #
  # Dropping `Crashed` leaves only `SuccessfulExit = false` (retry on failure),
  # matching the Linux daemon variant in modules/age.nix, so the job runs once
  # at login and only re-runs if decryption actually fails.
  launchd.agents.activate-agenix.config.KeepAlive = lib.mkForce {
    SuccessfulExit = false;
  };
}
