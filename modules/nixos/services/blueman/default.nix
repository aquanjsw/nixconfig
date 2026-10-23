{ lib, config, ... }: {
  config = lib.mkIf config.programs.niri.enable {
    services.blueman = {
      enable = lib.mkDefault true;
    };
  };
}
