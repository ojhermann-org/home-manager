{ pkgs }:

let
  version = "0.82.3";

  platforms = {
    "aarch64-darwin" = {
      os = "darwin";
      arch = "arm64";
      hash = "sha256-uD18t53AbJM0jcHpdpfVnrYJx5RuFnKsUJTTT8u0LcA=";
    };
    "aarch64-linux" = {
      os = "linux";
      arch = "arm64";
      hash = "sha256-3240F6ujtvGSHVju/IxRdHjtGtJ7+s5S9Hgi70E5Sh0=";
    };
  };

  platform = platforms.${pkgs.stdenv.hostPlatform.system};

  src = pkgs.fetchurl {
    url = "https://hub.platform.engineering/binaries/pkgs/formae@${version}_${platform.os}-${platform.arch}.tgz";
    inherit (platform) hash;
  };
in
pkgs.stdenv.mkDerivation {
  pname = "formae";
  inherit version src;

  nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    pkgs.autoPatchelfHook
  ];

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m755 formae/bin/formae $out/bin/formae
  '';

  meta = {
    description = "Agentic Infrastructure-as-Code platform for cloud resource management";
    homepage = "https://formae.io";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
    ];
  };
}
