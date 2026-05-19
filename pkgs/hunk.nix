{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "0.11.1";
  assets = {
    aarch64-darwin = {
      name = "hunkdiff-darwin-arm64";
      hash = "sha256-TjSrDxHjYXasXEr+O0Nid9PcJRvZIbRK/lP7DrGHtZo=";
    };
    x86_64-darwin = {
      name = "hunkdiff-darwin-x64";
      hash = "sha256-dq8D7a6s0MUIATq2tgMi0VYIp00qWqLNddiUlIUcazo=";
    };
    aarch64-linux = {
      name = "hunkdiff-linux-arm64";
      hash = "sha256-vFzAW+6fXj6kNWm7V7Oj46F8xfjLMssrWti158uQ8ec=";
    };
    x86_64-linux = {
      name = "hunkdiff-linux-x64";
      hash = "sha256-XQkhUXxA9Vsd1ILgyo3cRqrOTfYNgVSUyiY9ZnQYchQ=";
    };
  };
  asset =
    assets.${stdenv.hostPlatform.system}
      or (throw "hunk is not available for ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "hunk";
  inherit version;

  src = fetchurl {
    url = "https://github.com/modem-dev/hunk/releases/download/v${version}/${asset.name}.tar.gz";
    inherit (asset) hash;
  };

  sourceRoot = asset.name;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.libc
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 hunk $out/bin/hunk

    runHook postInstall
  '';

  meta = {
    description = "Review-first terminal diff viewer for agent-authored changesets";
    homepage = "https://github.com/modem-dev/hunk";
    license = lib.licenses.mit;
    mainProgram = "hunk";
    platforms = builtins.attrNames assets;
  };
}
