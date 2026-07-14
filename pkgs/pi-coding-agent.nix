{
  lib,
  buildNpmPackage,
  fetchzip,
  npm-lockfile-fix,
}:

buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "0.80.7";

  src = fetchzip {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-B0DrLZPYXTUAG8q13DKagSPJobgourXXOgVjMgaJGQ0=";
    postFetch = ''
      ${lib.getExe npm-lockfile-fix} $out/npm-shrinkwrap.json
    '';
  };

  npmDepsHash = "sha256-877PUl4olE3M346p86z1+3YyDKJLqZ6RH/BsouIg52g=";
  dontNpmBuild = true;
  npmRebuildFlags = [ "--ignore-scripts" ];

  postPatch = ''
    sed -i '/^\t"devDependencies": {/,/^\t},/d' package.json
  '';
}
