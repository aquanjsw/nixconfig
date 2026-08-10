{
  hostName,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ./gpu
  ];

  isBareMetal = true;

  tunnel.client.enable = true;
  services.tailscale.enable = true;

  services.beszel.agent.enable = true;

  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  users.users.${config.user} = {
    packages = with pkgs; [
    ];
  };

  environment.systemPackages = with pkgs; [
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  swapfileSize = 8 * 1024;

  networking.hostName = hostName;

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
