{
  pkgs,
  config,
  utils,
  lib,
  ...
}:
let
  runtimeDirectory = "json-deployment";
  deploymentType = lib.types.submodule (
    { name, ... }:
    {
      options = {
        settings = lib.mkOption {
          type = lib.types.attrs;
        };
        path = lib.mkOption {
          readOnly = true;
          default = "/var/run/${runtimeDirectory}/${name}.json";
        };
      };
    }
  );
in
{
  options.jsonDeployment.deployments = lib.mkOption {
    type = lib.types.attrsOf deploymentType;
    default = { };
    description = "Nix objects -> JSON files with secrets replacement";
  };
  config.systemd.services = builtins.listToAttrs (
    lib.forEach (lib.attrsToList config.jsonDeployment.deployments) (deployment: {
      name = "json-deployment-${deployment.name}";
      value = {
        description = "JSON deployment ${deployment.name}";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RuntimeDirectory = runtimeDirectory;
          RuntimeDirectoryPreserve = true;
          ExecStart =
            let
              script = pkgs.writeShellScript "json-deployment-${deployment.name}" ''
                ${utils.genJqSecretsReplacementSnippet deployment.value.settings deployment.value.path}
              '';
            in
            "+${script}";
        };
      };
    })
  );
}
