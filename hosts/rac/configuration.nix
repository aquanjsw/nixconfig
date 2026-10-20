{
  pkgs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ./i18n
  ];

  rag = {
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.systemPackages =
    (with pkgs; [
      usbutils # lsusb
      pciutils # lspci
      ruff
      ty
    ])
    ++ (with pkgs-unstable; [
      niri
      fuzzel
      ghostty
      wl-clipboard
      google-chrome
      zed-editor
      xdg-utils
      qq
    ]);

  boot.loader.systemd-boot.enable = true;

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
