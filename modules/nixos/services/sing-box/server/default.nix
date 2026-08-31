{
  config,
  lib,
  ...
}:
let
  cfg = config.rag.services.sing-box;
  vless-uuids = map (vless-uuid: {
    _secret = config.age.secrets."by-group/vless-uuids/${vless-uuid}".path;
  }) (builtins.attrNames config.rag.secret-registry.by-group.vless-uuids);
in
{
  options.rag.services.sing-box.server = {
    domain = lib.mkOption {
      default = config.rag.rootDomain;
      readOnly = true;
    };
  };
  config = lib.mkIf (config.services.sing-box.enable && cfg.role == "server") {
    services.sing-box.settings = import ./settings.nix {
      inherit vless-uuids;
      api-port = cfg.api-port;
      server-name = cfg.server.domain;
      handshake-server = cfg.server.domain;
      handshake-port = config.services.caddy.httpsPort;
      reality-private-key = {
        _secret = config.age.secrets."by-host/${config.networking.hostName}/reality-private-key".path;
      };
      res-password = {
        _secret = config.age.secrets."by-host/${config.networking.hostName}/res-password".path;
      };
      api-secret = {
        _secret = config.age.secrets."by-host/${config.networking.hostName}/sing-box-api-secret".path;
      };
    };
  };
}
