{ config, lib, ... }:
let
  cfg = config.rag.services.sing-box;
in
{
  imports = [
    ./client
    ./server
  ];

  options.rag.services.sing-box = {
    role = lib.mkOption {
      type = lib.types.enum [
        "client"
        "server"
      ];
      description = "Role of the sing-box service (client or server)";
    };
    api-port = lib.mkOption {
      type = lib.types.port;
      default = 2436;
      description = "Port for the sing-box API";
    };
  };

  config = {
    environment.variables = {
      BOX_API_URL = "http://127.0.0.1:${toString cfg.api-port}";
    };
    services.caddy.virtualHosts."http://sing-box.${config.rag.domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString cfg.api-port}
    '';
  };
}
