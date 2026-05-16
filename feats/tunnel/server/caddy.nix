{
  config,
  lib,
  ...
}: lib.mkIf config.tunnel.server.enable {

  services.caddy = {
    httpsPort = 1443;
    globalConfig = ''
      default_bind 127.0.0.1
    '';
  };

  assertions = [
    {
      assertion = config.services.caddy.enable;
      message = "Tunnel server requires caddy to be enabled.";
    }
  ];
}
