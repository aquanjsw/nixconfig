{
  config ? {
    networking.hostName = "cat";
    rag.secret-registry = import ../../../secret-registry.nix { };
  },
  ...
}:
let
  secret-registry = config.rag.secret-registry;

  # Filter by hostname
  secrets_h = builtins.mapAttrs (
    secret-type: type-value:
    (builtins.listToAttrs (
      map (
        group-name:
        let
          group-value = type-value.${group-name};
        in
        {
          name = group-name;
          value = (
            builtins.listToAttrs (
              builtins.concatMap (
                secret-name:
                let
                  secret-value = group-value.${secret-name};
                in
                (
                  if (builtins.elem config.networking.hostName secret-value.hostnames) then
                    [
                      {
                        name = secret-name;
                        value = {
                          file = secret-value.path;
                        };
                      }
                    ]
                  else
                    [ ]
                )
              ) (builtins.attrNames group-value)
            )
          );
        }
      ) (builtins.attrNames type-value)
    ))
  ) secret-registry;

  # merge `any` and `hostName` group
  secrets_m = {
    by-group = secrets_h.by-group;
    by-host.${config.networking.hostName} =
      secrets_h.by-host.any
      // (
        if builtins.hasAttr config.networking.hostName secrets_h.by-host then
          secrets_h.by-host.${config.networking.hostName}
        else
          { }
      );
  };

  # Filter out empty groups
  secrets_f = builtins.mapAttrs (
    secret-type: type-value:
    (builtins.listToAttrs (
      builtins.concatMap (
        group-name:
        let
          group-value = type-value.${group-name};
        in
        (
          if group-value == { } then
            [ ]
          else
            [
              {
                name = group-name;
                value = group-value;
              }
            ]
        )
      ) (builtins.attrNames type-value)
    ))
  ) secrets_m;

  secrets = builtins.listToAttrs (
    builtins.concatMap (
      secret-type:
      let
        type-value = secrets_f.${secret-type};
      in
      (builtins.concatMap (
        group-name:
        let
          group-value = type-value.${group-name};
        in
        (map (
          secret-name:
          let
            secret-value = group-value.${secret-name};
          in
          {
            name = "${secret-type}/${group-name}/${secret-name}";
            value = {
              file = secret-value.file;
            };
          }
        ) (builtins.attrNames group-value))
      ) (builtins.attrNames type-value))
    ) (builtins.attrNames secrets_f)
  );
in
{
  config.age.secrets = secrets;
}
