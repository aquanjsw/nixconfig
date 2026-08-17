{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./caddy
    ./web-apps
  ];

  config = {
    rag = {
      services.sing-box.role = "server";
      ${config.networking.hostName}.services.web-apps.subscription.enable = true;
      system.swap.fileSize = 1024;
    };

    services.caddy.enable = true;
    services.qemuGuest.enable = true;
    services.cloudflare-warp.enable = true;

    environment.systemPackages = with pkgs; [
    ];

    networking.hostName = "cat";
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

    boot.loader.systemd-boot.enable = false;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.enable = true;

    system.stateVersion = "25.11";
  };
}

# vim: sts=2 sw=2 et ai
