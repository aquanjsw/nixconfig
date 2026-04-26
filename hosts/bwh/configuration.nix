{ config, lib, inputs, ... }: {

  imports = [
    inputs.agenix.nixosModules.default 
    ./hardware-configuration.nix
  ];

  config = {

    limited.enable = true;
    oversea.enable = true;
    tunnel.server.enable = true;

    zramSwap.memoryPercent = 100;
    
    networking.hostName = "bwh";

    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.enable = true;

    system.stateVersion = "25.11";
  };
}

# vim: sts=2 sw=2 et ai
