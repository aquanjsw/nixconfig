{
  config,
  pkgs,
  lib,
  ...
}:
let
  script =
    with pkgs;
    writeShellApplication {
      name = "dynamic-theme";
      runtimeInputs = [
        jq
        curl
        glib
        gsettings-desktop-schemas
      ];
      runtimeEnv = {
        XDG_DATA_DIRS = "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}";
      };
      text = builtins.readFile ./dynamic-theme.sh;
    };
in
{
  config = lib.mkIf config.programs.niri.enable {
    systemd.user.services.dynamic-theme = {
      description = "Light or Dark based on time of day";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${script}/bin/dynamic-theme";
      };
    };
    systemd.user.timers.dynamic-theme = {
      description = "Check and update theme periodically";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      timerConfig = {
        OnActiveSec = "10s";
        OnUnitActiveSec = "10m";
      };
    };
  };
}
