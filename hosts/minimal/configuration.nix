{ config, pkgs, lib, ... }: {
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  tunnel.client.enable = true;

  system.stateVersion = "25.11";
}

# vim: sts=2 sw=2 et ai
