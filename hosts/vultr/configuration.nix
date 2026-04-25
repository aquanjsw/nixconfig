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

    caddy.baseDomain = { _secret = config.age.secrets.vultr-domain.path; };

    networking.hostName = "vultr";

    nix.settings.substituters = [ "https://cache.nixos.org" ];

    boot.loader.systemd-boot.enable = false;
    boot.loader.efi.canTouchEfiVariables = false;
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = true;

    system.stateVersion = "25.11";
  };
}

# vim: sts=2 sw=2 et ai
