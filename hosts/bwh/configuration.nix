{ config, lib, inputs, ... }: {

  imports = [
    inputs.agenix.nixosModules.default 
    inputs.web-server.nixosModules.default
    ./hardware-configuration.nix
  ];

  config = {

    limited.enable = true;
    oversea.enable = true;
    tunnel.server.enable = true;

    services.web-server.enable = true;
    services.web-server.subscriptionPath = config.tunnel.subscriptionPath;
    services.web-server.envFile = config.age.secrets.django-env.path;

    zramSwap.memoryPercent = 100;
    
    networking.hostName = "bwh";

    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.enable = true;

    system.stateVersion = "25.11";
  };
}

# vim: sts=2 sw=2 et ai
