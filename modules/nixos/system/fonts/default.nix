{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.programs.niri.enable {
    fonts = {
      packages = with pkgs; [
        source-han-sans
        nerd-fonts.symbols-only
        nerd-fonts.noto
      ];
      fontconfig.defaultFonts = {
        sansSerif = [ "Source Han Sans SC" ]; # Make SC higher priority than JP, etc.
      };
    };
  };
}
