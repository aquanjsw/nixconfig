{ config, pkgs, lib, ... }: {

  imports = [ ./hardware-configuration.nix ];

  tunnel.client.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "minimal";

  system.stateVersion = "25.11";
}

# vim: sts=2 sw=2 et ai
