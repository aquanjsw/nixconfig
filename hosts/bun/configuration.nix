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
  ];

  isBareMetal = true;

  services.sing-box.enable = true;
  services.beszel.agent.enable = true;

  hardware.graphics.enable = false;

  users.users.${config.user} = {
    packages = with pkgs; [
    ];
  };

  environment.systemPackages = with pkgs; [
    qemu
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "bun";
  networking.bridges.br0.interfaces = [ "enp3s0" ];
  networking.interfaces.enp3s0.useDHCP = false;
  networking.interfaces.br0.useDHCP = true;

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
