{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.rag.programs.apprise;
  hostname = config.networking.hostName;
in
{
  options.rag.programs.apprise = {
    enable = lib.mkEnableOption "apprise";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.apprise ];
    environment.etc."apprise.yaml" = {
      enable = true;
      source = config.age.secrets."by-host/${hostname}/apprise".path;
    };
  };
}
