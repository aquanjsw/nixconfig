{
  lib,
  config,
  ...
}:
let
  dashboardDomain = "dashboard.${config.domain}";
  dashboardPort = 9090;
in
{
  options.tunnel.server.settings = lib.mkOption {
    default = {
      log = {
        disabled = false;
        level = "debug";
        timestamp = false;
      };
      outbounds = [
        {
          type = "direct";
        }
      ];
      inbounds = [
        {
          type = "vless";
          listen = "::0";
          listen_port = 443;
          users = [
            {
              uuid._secret = config.age.secrets.vless-uuid.path;
              flow = "xtls-rprx-vision";
            }
            {
              uuid._secret = config.age.secrets.vless-uuid-430.path;
              flow = "xtls-rprx-vision";
            }
          ];
          tls = {
            enabled = true;
            server_name = config.domain;
            reality = {
              enabled = true;
              private_key._secret = config.age.secrets.reality-private-key.path;
              short_id = [ "" ];
              handshake = {
                server = config.domain;
                server_port = config.services.caddy.httpsPort;
              };
            };
          };
          transport = {
            type = "httpupgrade";
          };
        }
      ];
    };
    readOnly = true;
  };
  options.tunnel.server.enable = lib.mkEnableOption "tunnel server";

  config = lib.mkIf config.tunnel.server.enable {
    services.caddy.virtualHosts."${dashboardDomain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString dashboardPort}
    '';
    services.sing-box = {
      enable = true;
      settings = config.tunnel.server.settings;
    };
    age.secrets = {
      reality-private-key.file = config.paths.secrets + "/reality-private-key.age";
      vless-uuid-430.file = config.paths.secrets + "/vless-uuid-430.age";
    };
    assertions = [
      {
        assertion = config.services.caddy.enable;
        message = "caddy not enabled";
      }
      {
        assertion = lib.hasAttr config.domain config.services.caddy.virtualHosts;
        message = "caddy virtual host for ${config.domain} not found";
      }
    ];
  };
}
