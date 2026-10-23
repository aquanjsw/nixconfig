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
    ./waybar
  ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  virtualisation.podman.enable = true;
  programs.nm-applet.enable = true;

  home-manager.users.rag = {
    services.awww.enable = true;
    programs.distrobox.enable = true;
    programs.waybar.enable = true;
    services.cliphist.enable = true;
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
      libnotify
      usbutils # lsusb
      pciutils # lspci
      ruff
      ty
      hyprpicker
      python3
      propertree
      xwayland-satellite
      fuzzel
      ghostty
      wl-clipboard
      xdg-utils # xdg-open
      mako
    ])
    ++ (with pkgs-unstable; [
      google-chrome
      zed
      qq
    ]);

  boot.loader.systemd-boot.enable = true;

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
