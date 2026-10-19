{ config, lib, ... }:
let
  cfg = config.rag.services.sing-box;
in
{
  imports = [ ./tailscale-cert-dumper.nix ];

  options.rag.services.sing-box.client = {
    settings = lib.mkOption {
      default = ./settings.nix;
      readOnly = true;
    };
  };
  config = lib.mkIf (config.services.sing-box.enable && cfg.role == "client") {
    services.sing-box.settings = import cfg.client.settings {
      server = cfg.server.domain;
      uuid = {
        _secret = config.sops.secrets."sing-box/uuids/default".path;
      };
      reality-public-key = {
        _secret = config.sops.secrets."sing-box/reality/public-key".path;
      };
      ts-auth-key = {
        _secret = config.sops.secrets.ts-auth-key.path;
      };
      api-port = cfg.api-port;
    };
  };
}
