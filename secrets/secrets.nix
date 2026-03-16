let
  keys = import ../lib/keys.nix;
  secrets = [
    "smtp.age"
    "vercel.age"
    "vpn.age"
    "zfs.age"
  ];
in
builtins.listToAttrs (
  map (s: {
    name = s;
    value.publicKeys = builtins.attrValues keys.age;
  }) secrets
)
