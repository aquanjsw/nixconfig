{
  utils,
  pkgs,
  config,
  lib,
  ...
}:
let
  runtimeDirectory = "tunnel-subscriptions";

  subscriptionType = lib.types.submodule (
    { name, ... }:
    {
      options = {
        settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
        };
        path = lib.mkOption {
          default = "/run/${runtimeDirectory}/${name}.json";
          readOnly = true;
        };
      };
    }
  );
in
{
  options.tunnel.subscription = lib.mkOption {
    type = lib.types.attrsOf subscriptionType;
    default = { };
  };
  options.tunnel.subscriptionDomain = lib.mkOption {
    default = "subscription";
    readOnly = true;
  };

  config = lib.mkIf config.services.xray.enable {

    systemd.services.tunnel-subscriptions-deployer = {
      description = "Deploy tunnel subscriptions";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RuntimeDirectory = runtimeDirectory;
        RuntimeDirectoryPreserve = "yes";
        ExecStart =
          let
            script = pkgs.writeShellScript "tunnel-subscriptions-deployer" ''
              ${lib.concatStringsSep "\n" (
                map (subscription: utils.genJqSecretsReplacementSnippet subscription.settings subscription.path) (
                  lib.attrValues config.tunnel.subscription
                )
              )}
            '';
          in
          "+${script}";
      };
    };

    tunnel.subscription.sing-box.settings = config.services.sing-box.settings;
  };
}
