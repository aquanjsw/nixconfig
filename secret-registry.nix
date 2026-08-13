{
  lib ? (import <nixpkgs> { }).lib,
  ...
}:
let
  # Declare host permissions for each group here
  by-group-registry = {
    vless-uuids = {
      "430" = [ "cat" ];
      default = registered-hostnames;
    };
  };

  inherit (builtins)
    mapAttrs
    listToAttrs
    attrNames
    readDir
    ;

  by-group = mapAttrs (
    groupname: groupvalue:
    (mapAttrs (secretname: secretvalue: {
      hostnames = secretvalue;
      path = ./secrets/by-group/${groupname}/${secretname}.age;
    }) groupvalue)
  ) by-group-registry;

  pubkey-registry = import ./pubkey-registry.nix;
  registered-hostnames = attrNames pubkey-registry;

  by-host = listToAttrs (
    map (hostname: {
      name = hostname;
      value = (
        listToAttrs (
          map (
            filename:
            let
              hostnames = if (hostname == "any") then registered-hostnames else [ hostname ];
              stem = lib.removeSuffix ".age" filename;
              path = ./secrets/by-host/${hostname}/${filename};
            in
            {
              name = stem;
              value = {
                inherit hostnames path;
              };
            }
          ) (attrNames (readDir ./secrets/by-host/${hostname}))
        )
      );
    }) (attrNames (readDir ./secrets/by-host))
  );
in
{
  inherit by-group by-host;
}
