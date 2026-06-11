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

  dnf.enable = true;
  dnf.domain = "gecko.${config.domain}";

  isBareMetal = true;

  tunnel.client.enable = true;
  services.sing-box.settings.experimental.clash_api.access_control_allow_origin = [
    "http://gecko.${config.domain}"
  ];

  services.searx.enable = true;
  services.searx.settings.server.base_url = "http://gecko.${config.domain}";
  services.freellmapi.enable = true;
  services.open-webui.enable = true;
  services.beszel.agent.enable = true;
  services.jellyfin.enable = true;
  services.qbittorrent.enable = true;
  services.samba.enable = true;

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
