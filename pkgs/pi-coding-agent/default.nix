{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  stdenv,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-coding-agent";
  version = "0.99.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${finalAttrs.version}.tgz";
    hash = "sha256-ZoZZKtrqGQkshclPXUAyPb89sUHpDrPt6enocwKr3R0=";
  };

  # Upstream's shrinkwrap omits integrity hashes for its own workspace packages.
  # These hashes come from the corresponding official npm release metadata.
  postPatch = ''
    # The published CLI is prebuilt, and its shrinkwrap contains runtime deps only.
    ${jq}/bin/jq 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    ${jq}/bin/jq --slurpfile integrity ${./integrity.json} '
      .packages |= with_entries(
        if $integrity[0][.key] then .value.integrity = $integrity[0][.key] else . end
      )
    ' npm-shrinkwrap.json > npm-shrinkwrap.json.tmp
    mv npm-shrinkwrap.json.tmp npm-shrinkwrap.json
  '';

  npmDepsHash = "sha256-W3nbpczNYv2wjMWp3IZCOqZ5Uv4i4KOhi50lQ6WHFF4=";
  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Avoid auditing unused Linux ELF binaries on macOS.
    rm -r "$out/lib/node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-tui/native/linux"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  versionCheckProgram = "${placeholder "out"}/bin/pi";
  versionCheckProgramArg = "--version";
  versionCheckKeepEnvironment = [ "HOME" ];

  meta = {
    description = "Pi coding agent, installed from the official npm release";
    homepage = "https://pi.dev";
    license = lib.licenses.mit;
    mainProgram = "pi";
  };
})
