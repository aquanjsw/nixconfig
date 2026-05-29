{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  config = {

    isLimited = true;
    isOutside = true;
    tunnel.server.enable = true;
    web-app.enable = true;

    services.beszel.hub.enable = true;
    services.beszel.agent.enable = true;
    services.rustdesk-server.enable = true;
    services.rustdesk-server.signal.relayHosts = [ config.domain ];
    services.syncthing.enable = true;
    services.caddy.enable = true;
    services.caddy.virtualHosts = {
      "syncthing.${config.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString config.syncthing.guiPort}
      '';
    };

    networking.hostName = "bwh";
    networking.sits.ip6net = {
      local = "138.128.193.71";
      remote = "45.32.66.87";
      ttl = 255;
    };
    networking.interfaces.ip6net.ipv6 = {
      addresses = [
        {
          address = "2607:8700:5500:5b28::2";
          prefixLength = 64;
        }
      ];
      routes = [
        {
          address = "::";
          prefixLength = 0;
        }
      ];
    };

    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.enable = true;

    system.stateVersion = "25.11";
  };
}

# vim: sts=2 sw=2 et ai
