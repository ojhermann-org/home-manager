{
  lib,
  stdenv,
  fetchzip,
  makeWrapper,
  nodejs,
  procps,
  bubblewrap,
  socat,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "claude-code";
  version = "2.1.117";

  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${finalAttrs.version}.tgz";
    hash = "sha256-8dRSs6GCwX1bfpz5tKzk6OhmG0aFfcvQOgv2+VK04gg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/claude-code $out/bin

    cp cli.js $out/lib/claude-code/
    substituteInPlace $out/lib/claude-code/cli.js \
      --replace-fail '#!/bin/sh' '#!/usr/bin/env sh'

    makeWrapper ${nodejs}/bin/node $out/bin/claude \
      --add-flags "$out/lib/claude-code/cli.js" \
      --set DISABLE_AUTOUPDATER 1 \
      --set DISABLE_INSTALLATION_CHECKS 1 \
      --unset DEV \
      --prefix PATH : ${
        lib.makeBinPath (
          [ procps ]
          ++ lib.optionals stdenv.hostPlatform.isLinux [
            bubblewrap
            socat
          ]
        )
      }

    runHook postInstall
  '';

  meta = {
    description = "Agentic coding tool that lives in your terminal";
    homepage = "https://github.com/anthropics/claude-code";
    license = lib.licenses.unfree;
    mainProgram = "claude";
    platforms = lib.platforms.unix;
  };
})
