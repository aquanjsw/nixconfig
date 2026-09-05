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
    ./jellyfin
    ./dns-record-syncer
    ./ipv6
  ];

  config = {
    rag = {
      utils.dns-record-syncer.enable = true;
      domain = config.rag.rootDomain;
      services.sing-box.role = "server";
      ${config.networking.hostName} = {
        services.web-apps.subscription.enable = true;
        ipv6.enable = true;
      };
      system.swap.fileSize = 1024;
    };

    services.caddy.enable = true;
    services.qemuGuest.enable = true;

    environment.systemPackages = with pkgs; [
    ];

    networking.hostName = "cat";
    boot.loader.systemd-boot.enable = false;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.enable = true;
    boot.kernel.sysctl = {
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
    };

    # it's safe to gc all, as bwh has external backup
    nix.gc.options = "-d";

    system.stateVersion = "25.11";
  };
}

# vim: sts=2 sw=2 et ai
