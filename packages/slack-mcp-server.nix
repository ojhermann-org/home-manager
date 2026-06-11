{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

# korotovsky/slack-mcp-server — not in nixpkgs, so we build it from source and
# pin it here for reproducibility. Bump `version` + `hash`, then set
# `vendorHash = lib.fakeHash` and rebuild to learn the new vendor hash.
buildGoModule rec {
  pname = "slack-mcp-server";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "korotovsky";
    repo = "slack-mcp-server";
    rev = "v${version}";
    hash = "sha256-I4f6yKV0BXtaxnqi/XNID+Pwl2mWjSqxIHhb07U7sc4=";
  };

  vendorHash = "sha256-+uQRODO9oL8mGKBmdghTxE6R9Fz+3GJFVTi17306gT8=";

  # Only the server entrypoint; skips building any helper commands.
  subPackages = [ "cmd/slack-mcp-server" ];

  # Trim binary size; this is a CLI server, not a debuggable library.
  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  meta = {
    description = "Powerful MCP Slack server (channels, search, DMs, history)";
    homepage = "https://github.com/korotovsky/slack-mcp-server";
    license = lib.licenses.mit;
    mainProgram = "slack-mcp-server";
  };
}
