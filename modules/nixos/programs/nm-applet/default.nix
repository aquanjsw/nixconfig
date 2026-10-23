{ lib, config, ... }: {
  config = lib.mkIf config.programs.niri.enable {
    programs.nm-applet = {
      enable = lib.mkDefault true;
    };
  };
}
