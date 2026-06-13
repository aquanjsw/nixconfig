{
  config,
  lib,
  ...
}:
{
  options.services.tailscale.socksPort = lib.mkOption {
    type = lib.types.port;
    default = 1055;
    description = "socks5 server port in userspace networking";
  };

  config.services.tailscale = {
    extraDaemonFlags = [
      "--socks5-server 127.0.0.1:${toString config.services.tailscale.socksPort}"
    ];
    extraSetFlags = [
      "--operator=${config.user}"
    ];
  };
}
