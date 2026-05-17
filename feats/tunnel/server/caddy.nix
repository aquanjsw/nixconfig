{
  config,
  lib,
  ...
}:
lib.mkIf config.tunnel.server.enable {

  services.caddy.httpsPort = 1443;

  assertions = [
    {
      assertion = config.services.caddy.enable;
      message = "Tunnel server requires caddy to be enabled.";
    }
  ];
}
