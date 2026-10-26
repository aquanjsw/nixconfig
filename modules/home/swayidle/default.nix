{
  pkgs,
  osConfig,
  lib,
  ...
}:
let
  DEBUG = false;
  timeouts =
    if DEBUG then
      rec {
        dim = 30;
        powerOffMonitor = dim + 5;
        lock = powerOffMonitor + 5;
        suspend = lock + 5;
      }
    else
      rec {
        dim = 600;
        powerOffMonitor = dim + 10;
        lock = powerOffMonitor + 60;
        suspend = lock + 60;
      };
  lockCommand = "${pkgs.swaylock}/bin/swaylock -f";
in
{
  config = lib.mkIf osConfig.programs.niri.enable {
    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = timeouts.dim;
          command = "${pkgs.systemd}/bin/busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d -0.5";
          resumeCommand = "${pkgs.systemd}/bin/busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d +0.5";
        }
        {
          timeout = timeouts.powerOffMonitor;
          command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
          resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
        }
        {
          timeout = timeouts.lock;
          command = lockCommand;
        }
        {
          timeout = timeouts.suspend;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
      events = {
        before-sleep = lockCommand;
      };
    };
  };
}
