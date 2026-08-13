let
  pubkey-registry = import ./pubkey-registry.nix;
  users = builtins.attrValues (builtins.mapAttrs (name: value: value.user) pubkey-registry);
  secret-registry = import ./secret-registry.nix { };
  genKeys = hostnames: (map (hostname: pubkey-registry.${hostname}.system) hostnames);
  secret-records = builtins.concatMap (
    secret-sets:
    (builtins.concatMap (secret-set: (builtins.attrValues secret-set)) (
      builtins.attrValues secret-sets
    ))
  ) (builtins.attrValues secret-registry);
  secrets = builtins.listToAttrs (
    map (record: {
      name = toString record.path;
      value = {
        publicKeys = users ++ genKeys record.hostnames;
      };
    }) secret-records
  );
in
secrets

# vim: sts=2 sw=2 et ai
