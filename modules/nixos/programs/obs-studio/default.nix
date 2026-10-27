{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.obs-studio;
in
{
  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      package = (
        pkgs.obs-studio.override {
          cudaSupport = builtins.elem "nvidia" config.services.xserver.videoDrivers;
        }
      );
    };
  };
}
