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

  home-manager.users.rag = {
    services.awww.enable = true;
  };

  rag = {
  };

  programs.niri = {
    enable = true;
    useNautilus = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  services.geoclue2.enable = true;

  environment.systemPackages =
    (with pkgs; [
      usbutils # lsusb
      pciutils # lspci
      ruff
      ty
    ])
    ++ (with pkgs-unstable; [
      glib
      gsettings-desktop-schemas
      fuzzel
      ghostty
      wl-clipboard
      google-chrome
      (symlinkJoin {
        name = "zed";
        paths = [ zed-editor ];
        postBuild = ''
          ln -s $out/bin/zeditor $out/bin/zed
        '';
      })
      xdg-utils
      qq
      mako
    ]);

  boot.loader.systemd-boot.enable = true;

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
