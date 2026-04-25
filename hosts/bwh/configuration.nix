{ config, lib, modulesPath, inputs, ... }: {

  imports = [
    inputs.agenix.nixosModules.default 
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  config = {
    
    tunnel.server.enable = true;

    caddy.baseDomain = config.age.secrets.bwh-domain.path;

    networking.hostName = "bwh";

    nix.settings.substituters = [ "https://cache.nixos.org" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    system.stateVersion = "25.11";
  };
}

# vim: sts=2 sw=2 et ai
