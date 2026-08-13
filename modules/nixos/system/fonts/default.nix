{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.services.jellyfin.enable {
    fonts.packages = with pkgs; [
      noto-fonts-cjk-sans
    ];
  };
}
