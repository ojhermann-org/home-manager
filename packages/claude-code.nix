{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  procps,
  bubblewrap,
  socat,
}:
let
  version = "2.1.126";

  sources = {
    "aarch64-darwin" = {
      pkg = "darwin-arm64";
      hash = "sha256-Il9MGrnnIV3i86cU3BjslGEdVodnV50VW3f2DEjSlMk=";
    };
    "x86_64-linux" = {
      pkg = "linux-x64";
      hash = "sha256-Il9MGrnnIV3i86cU3BjslGEdVodnV50VW3f2DEjSlMk=";
    };
    "aarch64-linux" = {
      pkg = "linux-arm64";
      hash = "sha256-Il9MGrnnIV3i86cU3BjslGEdVodnV50VW3f2DEjSlMk=";
    };
  };

  src_info =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "claude-code";
  inherit version;

  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code-${src_info.pkg}/-/claude-code-${src_info.pkg}-${version}.tgz";
    inherit (src_info) hash;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    procps
    bubblewrap
    socat
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp claude $out/bin/claude
    chmod +x $out/bin/claude

    runHook postInstall
  '';

  meta = {
    description = "Agentic coding tool that lives in your terminal";
    homepage = "https://github.com/anthropics/claude-code";
    license = lib.licenses.unfree;
    mainProgram = "claude";
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
