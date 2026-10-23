{
  osConfig,
  lib,
  ...
}:
{
  services.awww = lib.mkIf osConfig.programs.niri.enable {
    enable = lib.mkDefault true;
    extraArgs = [ ];
  };
}
