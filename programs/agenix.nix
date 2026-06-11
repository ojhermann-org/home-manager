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
  #   agenix -e secrets/slack-bot-token.age
  # (run from the repo root). The committed file is a placeholder until then.
  age.secrets."slack-bot-token".file = ../secrets/slack-bot-token.age;
}
