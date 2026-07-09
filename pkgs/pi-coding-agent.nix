{
  lib,
  buildNpmPackage,
  fetchzip,
  npm-lockfile-fix,
}:

buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "0.80.5";

  src = fetchzip {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-5DZxrGLZQx10CCO7q8iCMkj4vSchV8Jz87nk1aONqHs=";
    postFetch = ''
      ${lib.getExe npm-lockfile-fix} $out/npm-shrinkwrap.json
    '';
  };

  npmDepsHash = "sha256-k3RJrINSrU7/6dGHLpxMJJmjZE79lz2HTQdPFwzFvis=";
  dontNpmBuild = true;
  npmRebuildFlags = [ "--ignore-scripts" ];

  postPatch = ''
    sed -i '/^\t"devDependencies": {/,/^\t},/d' package.json
  '';
}
