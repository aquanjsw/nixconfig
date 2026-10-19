{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  rag = {
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  environment.systemPackages =
    (with pkgs; [
      binutils # nm
      usbutils # lsusb
      pciutils # lspci
      ruff
      ty
      deploy-rs
    ])
    ++ (with pkgs-unstable; [
      firefox
      niri
      fuzzel
      ghostty
      xdg-utils
      wl-clipboard
      google-chrome
      zed-editor
      xdg-utils
    ]);

  boot.loader.systemd-boot.enable = true;

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
