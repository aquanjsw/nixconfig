{
  lib ? (import <nixpkgs> { }).lib,
  ...
}:
let
  # Declare attrs for each group here
  # Besides the `hostnames` attr, agenix attrs are valid too except for the `path`
  # by-group-registry = {
  #   group1 = {
  #     secret1 = {
  #       hostnames = [ "host1"];
  #       owner = "some";
  #     };
  #   };
  # };
  by-group-registry = {
    vless-uuids = {
      "430".hostnames = [ "cat" ];
      default.hostnames = registered-hostnames;
    };
  };

  # Simliar to by-group-registry except for non-existing `hostnames` attr
  by-host-registry = {
    any.apprise = {
      owner = "rag";
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
    (mapAttrs (
      secretname: secretAttrs:
      {
        path = ./secrets/by-group/${groupname}/${secretname}.age;
      }
      // secretAttrs
    ) groupvalue)
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
              extraAttrs =
                if
                  (builtins.hasAttr hostname by-host-registry && builtins.hasAttr stem by-host-registry.${hostname})
                then
                  by-host-registry.${hostname}.${stem}
                else
                  { };
            in
            {
              name = stem;
              value = {
                inherit hostnames path;
              }
              // extraAttrs;
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
