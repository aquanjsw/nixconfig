{ config, lib, ... }:
let
  cfg = config.rag.services.sing-box;
in
{
  options.rag.services.sing-box.client.settings = lib.mkOption {
    default = ./settings.nix;
    readOnly = true;
  };

  config = lib.mkIf (config.services.sing-box.enable && cfg.role == "client") {
    services.sing-box.settings = import cfg.client.settings {
      vless-server = cfg.server.name;
      vless-uuid = {
        _secret = config.age.secrets."by-group/vless-uuids/default".path;
      };
      reality-public-key = {
        _secret = config.age.secrets."by-host/${config.networking.hostName}/reality-public-key".path;
      };
    };

    # sing-box tun's NAT-PMP/UPnP-IGD/PCP traffic bypass will render sing-box's DNS
    # hijacking ineffective if the system DNS is set to in the bypass CIDRs, e.g.
    # the gateway IP.
    # Set system DNS to any IP outside the bypass CIDRs to avoid DNS hijacking issues.
    networking = {
      networkmanager.dns = "none";
      nameservers = [ "1.1.1.1" ];
    };

    # Disable tailscale's dns hijacking so that sing-box's tun can take over
    services.tailscale.extraUpFlags = [ "--accept-dns=false" ];
  };
}
