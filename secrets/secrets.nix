let
  keys = import ../lib/keys.nix;
  secrets = [
    "rex-netrc.age"
    "smtp.age"
    "vercel.age"
    "vpn.age"
    "zfs.age"
  ];
in
builtins.listToAttrs (
  map (s: {
    name = s;
    value.publicKeys = builtins.attrValues keys;
  }) secrets
)
