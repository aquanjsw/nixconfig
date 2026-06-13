{
  config,
  lib,
  ...
}:
{
  options.services.freellmapi.enable = lib.mkEnableOption "FreeLLM API server";
  options.services.freellmapi.bindPort = lib.mkOption {
    type = lib.types.port;
    default = 3001;
  };
  options.services.freellmapi.bindIP = lib.mkOption {
    default = "127.0.0.1";
  };

  config =
    let
      cfg = config.services.freellmapi;
    in
    (lib.mkIf cfg.enable {
      virtualisation.oci-containers.containers."freellmapi" = {
        image = "ghcr.io/tashfeenahmed/freellmapi:latest";
        autoStart = true;
        environment = {
          NODE_ENV = "production";
          PORT = "3001";
        };
        environmentFiles = [
          config.age.secrets.freellmapi.path
        ];
        volumes = [
          "freellmapi-data:/app/server/data:rw"
        ];
        ports = [
          "${cfg.bindIP}:${toString cfg.bindPort}:3001/tcp"
        ];
      };
      age.secrets.freellmapi.file = config.paths.secrets + "/freellmapi.age";
    });
}
