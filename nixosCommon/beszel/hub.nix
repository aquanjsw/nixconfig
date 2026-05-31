{
  lib,
  config,
  ...
}:
lib.mkIf config.services.beszel.hub.enable {
  services.caddy.virtualHosts = {
    "beszel.${config.domain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString config.services.beszel.hub.port}
    '';
  };
}
