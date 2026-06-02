{ lib, config, ... }:
lib.mkIf config.services.beszel.hub.enable {
  services.caddy.virtualHosts."${config.services.beszel.hub.domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString config.services.beszel.hub.port}
  '';
  assertions = [
    {
      assertion = config.services.caddy.enable;
      message = "beszel hub requires caddy to be enabled";
    }
  ];
}
