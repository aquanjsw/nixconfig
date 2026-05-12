{ config, pkgs, lib, ... }: {

  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  tunnel.client.enable = true;

  services.jellyfin.enable = true;

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  nix.settings.substituters = [ "https://cache.nixos-cuda.org" ];
  nix.settings.trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];

  users.users.rag = {
    packages = with pkgs; [
    ];
  };

  environment.systemPackages = with pkgs; [
    usbutils
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.services.lvm.enable = true;
  boot.initrd.availableKernelModules = [ "bcache" ];
  fileSystems."/data" = {
    device = lib.mkForce "/dev/bcache0";
    fsType = "xfs";
    options = [ "nofail" ];
  };

  networking.hostName = "lib5";

  system.stateVersion = "25.11";
}

# vim: sts=2 sw=2 et ai
