{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ./samba.nix
  ];

  isBareMetal = true;

  dnf.enable = true;
  dnf.domain = "gecko.${config.domain}";

  services.open-webui.enable = true;
  services.open-webui.port = 9080;
  services.open-webui.host = "0.0.0.0";

  services.sing-box.enable = true;
  services.beszel.agent.enable = true;
  services.jellyfin.enable = true;
  services.qbittorrent.enable = true;
  services.samba.enable = true;
  services.syncthing.enable = true;

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  nix.settings.substituters = [ "https://cache.nixos-cuda.org" ];
  nix.settings.trusted-public-keys = [
    "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
  ];

  users.users.${config.user} = {
    packages =
      with pkgs;
      [
        nix-index
        go
        gopls
        delve
        gcc
        realcugan
      ]
      ++ (with pkgs.python3Packages; [
        huggingface-hub
      ]);
  };

  environment.systemPackages = with pkgs; [
    usbutils
    nvtopPackages.nvidia
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

  networking.hostName = "dog";

  swapfileSize = 8 * 1024;

  system.stateVersion = "25.11";
}

# vim: sts=2 sw=2 et ai
