{
  lib,
  config,
  ...
}:
lib.mkIf config.services.syncthing.enable (
  let
    guiPort = 8384;
  in
  {
    services.syncthing = {
      guiAddress = "0.0.0.0:${toString guiPort}";
      guiPasswordFile = config.age.secrets.syncthingGuiPassword.path;
    };

    services.caddy.virtualHosts."syncthing.${config.domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString guiPort}
    '';

    age.secrets.syncthingGuiPassword.file = config.paths.secrets + "/syncthingGuiPassword.age";

    assertions = [
      {
        assertion = config.services.caddy.enable;
        message = "Caddy must be enabled to reverse proxy the Syncthing GUI.";
      }
    ];
  }
)
