{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.programs.niri;
in
{
  config = lib.mkIf cfg.enable {
    programs.obs-studio.enable = true;
    programs.chromium.enable = true;
    services.kanata.enable = true;
    environment.enableAllTerminfo = true;
    environment.systemPackages =
      with pkgs;
      [
        libnotify
        hyprpicker
        xwayland-satellite
        wl-clipboard
        xdg-utils # xdg-open
        ghostty
        fuzzel
        mpv
      ]
      ++ (with pkgs-unstable; [
        google-chrome
        zed
        qq
      ]);

    programs.niri = {
      useNautilus = true;
    };
  };
}
