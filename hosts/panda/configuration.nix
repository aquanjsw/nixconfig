{
  config,
  pkgs,
  ...
}:
{
  isBareMetal = true;

  environment.systemPackages = with pkgs; [
  ];

  wsl.enable = true;
  wsl.defaultUser = config.user;

  networking.hostName = "panda";
  systemd.services.wpa_supplicant.enable = false;

  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "25.11";
}
