{
  hostName,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  isBareMetal = true;

  tunnel.client.enable = true;

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
      ]
      ++ (with pkgs.python3Packages; [
      ]);
  };

  environment.systemPackages = with pkgs; [
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.cudaSupport = true;

  networking.hostName = hostName;

  swapfileSize = 8 * 1024;

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
