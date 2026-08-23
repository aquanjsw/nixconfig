{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.services.jellyfin.enable {
    services.caddy.virtualHosts."j.${config.rag.domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:8096
    '';
  };
}
