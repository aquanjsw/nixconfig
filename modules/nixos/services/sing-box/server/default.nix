{
  config,
  lib,
  ...
}:
let
  cfg = config.rag.services.sing-box;
  domain = config.rag.rootDomain;
in
{
  options.rag.services.sing-box.server = {
    name = lib.mkOption {
      default = domain;
      readOnly = true;
    };
    domain = lib.mkOption {
      default = "sing-box.${domain}";
      readOnly = true;
    };
    settings = lib.mkOption {
      default = ./settings.nix;
      readOnly = true;
    };
    vless-uuids = lib.mkOption {
      default = map (vless-uuid: {
        _secret = config.age.secrets."by-group/vless-uuids/${vless-uuid}".path;
      }) (builtins.attrNames config.rag.secret-registry.by-group.vless-uuids);
      readOnly = true;
    };
    reality-private-key = lib.mkOption {
      default = {
        _secret = config.age.secrets."by-host/${config.networking.hostName}/reality-private-key".path;
      };
      readOnly = true;
    };
    res-password = lib.mkOption {
      default = {
        _secret = config.age.secrets."by-host/${config.networking.hostName}/res-password".path;
      };
      readOnly = true;
    };
    api-port = lib.mkOption {
      default = 2436;
      readOnly = true;
    };
    api-secret = lib.mkOption {
      default = {
        _secret = config.age.secrets."by-host/${config.networking.hostName}/sing-box-api-secret".path;
      };
      readOnly = true;
    };
  };
  config = lib.mkIf (config.services.sing-box.enable && cfg.role == "server") {
    services.sing-box.settings = import ./settings.nix {
      vless-uuids = cfg.server.vless-uuids;
      server-name = config.rag.domain;
      handshake-server = config.rag.domain;
      handshake-port = config.services.caddy.httpsPort;
      reality-private-key = cfg.server.reality-private-key;
      res-password = cfg.server.res-password;
      api-port = cfg.server.api-port;
      api-secret = cfg.server.api-secret;
    };

    environment.variables = {
      BOX_API_URL = "http://127.0.0.1:${toString cfg.server.api-port}";
    };

    services.caddy.virtualHosts."http://${cfg.server.domain}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.server.api-port}
      '';
    };
  };
}
