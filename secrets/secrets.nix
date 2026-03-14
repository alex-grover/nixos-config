let
  keys = import ../lib/keys.nix;
  secrets = [
    "smtp.age"
    "zfs.age"
  ];
in
builtins.listToAttrs (
  map (s: {
    name = s;
    value.publicKeys = builtins.attrValues keys.age;
  }) secrets
)
