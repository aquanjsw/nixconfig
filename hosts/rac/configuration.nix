{
  pkgs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  programs.niri.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  environment.systemPackages =
    (with pkgs; [
      usbutils # lsusb
      pciutils # lspci
      ruff
      ty
      propertree
    ])
    ++ (with pkgs-unstable; [
    ]);

  boot.loader.systemd-boot.enable = true;

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
