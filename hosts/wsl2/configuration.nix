{
  config,
  lib,
  pkgs,
  ...
}:
{
  isBareMetal = true;

  wsl.enable = true;
  wsl.defaultUser = config.user;

  networking.hostName = "wsl2";
  systemd.services.wpa_supplicant.enable = false;

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "25.11";
}
