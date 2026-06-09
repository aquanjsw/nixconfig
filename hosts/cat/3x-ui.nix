{
  config,
  lib,
  ...
}:
{
  options.services."3x-ui".enable = lib.mkEnableOption "3x-ui the panel for xray-core";
  options.services."3x-ui".port = lib.mkOption {
    type = lib.types.port;
    default = 2053;
  };

  config = lib.mkIf config.services."3x-ui".enable {

    virtualisation.oci-containers.containers."3x-ui" = {
      image = "ghcr.io/mhsanaei/3x-ui:latest";
      capabilities = {
        NET_ADMIN = true;
        NET_RAW = true;
      };
      volumes = [
        "3x-ui-data:/etc/x-ui"
        "3x-ui-cert:/root/cert"
      ];
      environment = {
        XRAY_VMESS_AEAD_FORCED = "false";
        XUI_ENABLE_FAIL2BAN = "true";
      };
      ports = [
        "${toString config.services."3x-ui".port}:2053/tcp"
      ];
      autoStart = true;
    };

    services.caddy.virtualHosts."3x-ui.${config.domain}".extraConfig = ''
      reverse_proxy localhost:${toString config.services."3x-ui".port}
    '';

    assertions = [
      {
        assertion = config.services.caddy.enable;
        message = "3x-ui requires caddy to be enabled";
      }
    ];
  };
}
