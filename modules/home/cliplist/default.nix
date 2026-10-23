{ lib, osConfig, ... }: {
  config = lib.mkIf osConfig.programs.niri.enable {
    services.cliphist = {
      enable = lib.mkDefault true;
    };
  };
}
