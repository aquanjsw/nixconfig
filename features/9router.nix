{
  config,
  lib,
  ...
}:
{
  options.services."9router".enable = lib.mkEnableOption "9router";
  options.services."9router".port = lib.mkOption {
    type = lib.types.port;
    default = 20128;
  };
  options.services."9router".host = lib.mkOption {
    default = "127.0.0.1";
  };
  options.services."9router".network = lib.mkOption {
    default = "9router";
  };

  config =
    let
      cfg = config.services."9router";
    in
    lib.mkIf cfg.enable {
      virtualisation.oci-containers.containers."9router" = {
        image = "ghcr.io/decolua/9router:0.5.8";
        autoStart = true;
        ports = [ "${cfg.host}:${toString cfg.port}:20128" ];
        networks = [ cfg.network ];
        environment = {
          DATA_DIR = "/app/data";
        };
        volumes = [ "9router-data:/app/data" ];
      };
      systemd.services."podman-9router".preStart = ''
        podman network create --ignore ${cfg.network}
      '';
    };
}
