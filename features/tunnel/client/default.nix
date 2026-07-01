{
  lib,
  config,
  ...
}:
{
  # For simplicity (other platforms' settings can be justified through web-app),
  # the settings here are optimized for linux
  options.tunnel.client.settings = lib.mkOption {
    default = import ./settings.nix { inherit config; };
    readOnly = true;
  };
  options.tunnel.client.enable = lib.mkEnableOption "tunnel client";

  config.services.sing-box = lib.mkIf config.tunnel.client.enable {
    enable = true;
    settings = config.tunnel.client.settings;
  };

  # sing-box tun's NAT-PMP/UPnP-IGD/PCP traffic bypass will render sing-box's DNS
  # hijacking ineffective if the system DNS is set to in the bypass CIDRs, e.g.
  # the gateway IP.
  # Set system DNS to any IP outside the bypass CIDRs to avoid DNS hijacking issues.
  config.networking = lib.mkIf config.tunnel.client.enable {
    networkmanager.dns = "none";
    nameservers = [ "1.1.1.1" ];
  };

  config.age.secrets = {
    reality-public-key.file = config.paths.secrets + "/reality-public-key.age";
  };
}
