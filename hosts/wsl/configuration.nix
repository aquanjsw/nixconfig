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

  system.stateVersion = "25.11";
}
