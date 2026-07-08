{
  lib,
  buildNpmPackage,
  fetchzip,
  npm-lockfile-fix,
}:

buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "0.80.3";

  src = fetchzip {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-nrDCKnN3Cmcmvoa72FFc+4MRfxJmvPX66DvPyuk6bFI=";
    postFetch = ''
      ${lib.getExe npm-lockfile-fix} $out/npm-shrinkwrap.json
    '';
  };

  npmDepsHash = "sha256-xKmIXXx3RXCN8Z+vUSS6MXCaN7VXGRt0TCkKKsLCvHE=";
  dontNpmBuild = true;
  npmRebuildFlags = [ "--ignore-scripts" ];

  postPatch = ''
    sed -i '/^\t"devDependencies": {/,/^\t},/d' package.json
  '';
}
