{ config, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./syncthing.nix
    ./web-server
    ./3x-ui.nix
  ];

  config = {

    isLimited = true;
    isOutside = true;
    web-app.enable = true;
    tunnel.server.enable = true;

    services.caddy.enable = true;
    services.beszel.agent.enable = true;
    services.beszel.hub.enable = true;
    services.tailscale.enable = true;
    services.tailscale.derper.enable = true;

    swapfileSize = 512;

    networking.hostName = "cat";
    networking.sits.ip6net = {
      local = "74.82.192.214";
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
