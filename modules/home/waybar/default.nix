{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (builtins) readFile fromJSON;
  dimHelper = pkgs.writeShellApplication {
    name = "dim-helper";
    runtimeInputs = with pkgs; [
      niri
      jq
    ];
    text = readFile ./dim-helper.sh;
  };
in
{
  config = lib.mkIf osConfig.programs.niri.enable {
    programs.waybar = {
      enable = lib.mkDefault true;
      settings = fromJSON (readFile ./settings.json);
      package = pkgs.symlinkJoin {
        name = "waybar-wrapped";
        paths = [
          pkgs.waybar
          dimHelper
        ];
      };
    };
    xdg.configFile = {
      "waybar/base.css".source = ./styles/base.css;
      "waybar/colors-dark.css".source = ./styles/colors-dark.css;
      "waybar/colors-light.css".source = ./styles/colors-light.css;
      "waybar/style-dark.css".source = ./styles/style-dark.css;
      "waybar/style-light.css".source = ./styles/style-light.css;
    };
  };
}
