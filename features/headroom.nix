{
  config,
  lib,
  ...
}:
{
  options.services.headroom.enable = lib.mkEnableOption "headroom";
  options.services.headroom.port = lib.mkOption {
    type = lib.types.port;
    default = 8787;
  };
  options.services.headroom.host = lib.mkOption {
    default = "127.0.0.1";
  };

  config =
    let
      cfg = config.services.headroom;
    in
    lib.mkIf cfg.enable {
      virtualisation.oci-containers.containers.headroom = {
        image = "ghcr.io/chopratejas/headroom:0.27.0";
        autoStart = true;
        ports = [ "${cfg.host}:${toString cfg.port}:8787" ];
        volumes = [ "headroom-data:/home/nonroot/.headroom" ];
        networks = lib.optional config.services."9router".enable config.services."9router".network;
      };
    };
}
