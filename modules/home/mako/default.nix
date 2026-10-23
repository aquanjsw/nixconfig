{
  lib,
  osConfig,
  ...
}:
{
  config = lib.mkIf osConfig.programs.niri.enable {
    services.mako = {
      enable = lib.mkDefault true;
      settings = {
        default-timeout = 5000;
      };
    };
  };
}
