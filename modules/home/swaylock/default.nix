{
  osConfig,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.programs.niri.enable {
    programs.swaylock = {
      enable = true;
    };
  };
}
