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

  services.comfyui.enable = true;
  services.comfyui.host = "0.0.0.0";
  services.freellmapi.enable = true;
  services.freellmapi.host = "0.0.0.0";
  services."9router".enable = true;
  services."9router".host = "0.0.0.0";
  services.headroom.enable = true;

  services.beszel.agent.enable = true;
  services.jellyfin.enable = true;
  services.qbittorrent.enable = true;
  services.samba.enable = true;
  services.tailscale.enable = true;

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
        opencode
        rtk
      ]
      ++ (with pkgs.python3Packages; [
        ipykernel # for zed lsp
        huggingface-hub
      ]);
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.services.lvm.enable = true;
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
