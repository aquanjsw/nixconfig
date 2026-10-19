{
  config,
  lib,
  ...
}:
let
  cfg = config.rag.services.sing-box;
in
{
  options.rag.services.sing-box.server = {
    domain = lib.mkOption {
      default = config.rag.rootDomain;
      readOnly = true;
    };
    uuidNames = lib.mkOption {
      default = [
        "default"
        "430"
      ];
    };
  };
  config = lib.mkIf (config.services.sing-box.enable && cfg.role == "server") (
    let
      uuids = map (uuidName: {
        _secret = config.sops.secrets."sing-box/uuids/${uuidName}".path;
      }) cfg.server.uuidNames;
    in
    {
      services.sing-box.settings = import ./settings.nix {
        inherit uuids;
        api-port = cfg.api-port;
        server = cfg.server.domain;
        handshake-server = cfg.server.domain;
        handshake-port = config.services.caddy.httpsPort;
        reality-private-key = {
          _secret = config.sops.secrets."sing-box/reality/private-key".path;
        };
        api-secret = {
          _secret = config.sops.secrets."sing-box/api-secret".path;
        };
        dataimpulse-passwd = {
          _secret = config.sops.secrets."dataimpulse-passwd".path;
        };
      };
    }
  );
}
