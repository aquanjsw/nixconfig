{ config, lib, ... }:
let
  cfg = config.rag.services.sing-box;
in
{
  options.rag.services.sing-box.client = {
    settings = lib.mkOption {
      default = ./settings.nix;
      readOnly = true;
    };
    api-port = lib.mkOption {
      type = lib.types.port;
      default = 2436;
    };
  };

  config = lib.mkIf (config.services.sing-box.enable && cfg.role == "client") {
    services.sing-box.settings = import cfg.client.settings {
      vless-server = cfg.server.name;
      vless-uuid = {
        _secret = config.age.secrets."by-group/vless-uuids/default".path;
      };
      reality-public-key = {
        _secret = config.age.secrets."by-host/${config.networking.hostName}/reality-public-key".path;
      };
      tailscale-auth-key = {
        _secret = config.age.secrets."by-host/${config.networking.hostName}/tailscale-auth-key".path;
      };
      api-port = cfg.client.api-port;
    };

    environment.variables = {
      BOX_API_URL = "http://127.0.0.1:${toString cfg.client.api-port}";
    };
  };
}
