{
  ...
}:
let
  inherit (builtins) readFile fromJSON;
in
{
  home-manager.users.rag = {
    programs.waybar = {
      settings = fromJSON (readFile ./settings.json);
      style = null;
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
