{ config, ... }:
{
  config.services.tailscale.authKeyFile =
    config.age.secrets."by-host/${config.networking.hostName}/tailscale-auth-key".path;
}
