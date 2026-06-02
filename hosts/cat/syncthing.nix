{ config, lib, ... }:
lib.mkIf config.services.syncthing.enable {
  services.caddy.virtualHosts."syncthing.${config.domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString config.syncthing.guiPort}
  '';
  assertions = [
    {
      assertion = config.services.caddy.enable;
      message = "syncthing requires caddy to be enabled";
    }
  ];
}
