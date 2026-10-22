{
  pkgs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    ./dynamic-theme
    ./hardware-configuration.nix
    ./disk-config.nix
    ./i18n
    ./awww
  ];

  virtualisation.podman.enable = true;
  home-manager.users.rag = {
    services.awww.enable = true;
    programs.distrobox.enable = true;
  };

  rag = {
  };

  programs.niri = {
    enable = true;
    useNautilus = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  environment.systemPackages =
    (with pkgs; [
      usbutils # lsusb
      pciutils # lspci
      ruff
      ty
      xwayland-satellite
      python3
      propertree
    ])
    ++ (with pkgs-unstable; [
      fuzzel
      ghostty
      wl-clipboard
      google-chrome
      zed
      xdg-utils # xdg-open
      qq
      mako
    ]);

  boot.loader.systemd-boot.enable = true;

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
