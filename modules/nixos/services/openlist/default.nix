{
  lib,
  config,
  ...
}:
let
  cfg = config.rag.services.openlist;
in
{
  options.rag.services.openlist = {
    enable = lib.mkEnableOption "OpenList service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 5244;
      description = "Port to listen on";
    };
    host = lib.mkOption {
      default = "127.0.0.1";
      description = "Host to listen on";
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.openlist = {
      image = "openlistteam/openlist:v4.2.5";
      autoStart = true;
      volumes = [
        "openlist-data:/opt/openlist/data"
      ];
      ports = [
        "${cfg.host}:${toString cfg.port}:5244"
      ];
      environment = {
        UMASK = "022";
      };
      user = "root:root";
    };
    services.caddy.virtualHosts."openlist.${config.rag.domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString cfg.port}
    '';
  };
}
