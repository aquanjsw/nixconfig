{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.wl-gammarelay-rs;
in
{
  options.services.wl-gammarelay-rs = {
    enable = lib.mkEnableOption "wl-gammarelay-rs, A simple program that provides DBus interface to control display temperature and brightness under wayland without flickering";
    package = lib.mkPackageOption pkgs "wl-gammarelay-rs" { };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.wl-gammarelay-rs = {
      Install = {
        WantedBy = [ config.wayland.systemd.target ];
      };

      Unit = {
        Description = "wl-gammarelay-rs daemon";
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
        PartOf = [ config.wayland.systemd.target ];
        After = [ config.wayland.systemd.target ];
      };

      Service = {
        ExecStart = "${lib.getExe cfg.package} run";
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
