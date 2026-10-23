{ config, lib, ... }:
{
  config = lib.mkIf config.programs.niri.enable {
    hardware.bluetooth = {
      enable = lib.mkDefault true;
    };
  };
}
