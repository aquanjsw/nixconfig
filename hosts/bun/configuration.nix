{
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

  hardware.graphics.enable = false;

  users.users.${config.user} = {
    packages = with pkgs; [
    ];
  };

  environment.systemPackages = with pkgs; [
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  swapfileSize = 8 * 1024;

  networking.hostName = "bun";

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
