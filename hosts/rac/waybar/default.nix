{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  home-manager.users.rag.programs.waybar = mkIf config.home-manager.users.rag.programs.waybar.enable {
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 20;
        modules-right = [
          "tray"
          "clock"
        ];
        clock = {
          tooltip = true;
          format = "{:%H:%M}";
          tooltip-format = "{:%Y-%m-%d %a}";
        };
      };
    };
  };
}
