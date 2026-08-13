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
    name = lib.mkOption {
      default = config.rag.domain;
      readOnly = true;
    };
  };
  config = lib.mkIf (config.services.sing-box.enable && cfg.role == "server") {
    services.sing-box.settings = import ./settings.nix {
      vless-uuids = map (vless-uuid: {
        _secret = config.age.secrets."by-group/vless-uuids/${vless-uuid}".path;
      }) (builtins.attrNames config.rag.secret-registry.by-group.vless-uuids);
      server-name = config.rag.domain;
      server-port = config.services.caddy.httpsPort;
      reality-private-key = {
        _secret = config.age.secrets."by-host/${config.networking.hostName}/reality-private-key".path;
      };
    };
  };
}
