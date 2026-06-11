{ config, ... }:
{
  imports = [
    ./server.nix
    ./client.nix
  ];

  config.age.secrets = {
    vless-uuid.file = config.paths.secrets + "/vless-uuid.age";
    clash-api-secret.file = config.paths.secrets + "/clash-api-secret.age";
  };
  config.assertions = [
    {
      assertion = !(config.tunnel.server.enable && config.tunnel.client.enable);
      message = "tunnel server and client cannot be enabled at the same time";
    }
  ];
}
