{
  lib,
  config,
  ...
}:
lib.mkIf config.tunnel.server.enable {
  services.xray.enable = true;
  services.xray.settings = {
    log = {
      loglevel = "error";
    };
    inbounds = [
      {
        port = 443;
        protocol = "vless";
        settings = {
          clients = [
            {
              id._secret = config.age.secrets.vless-uuid.path;
              flow = "xtls-rprx-vision";
            }
          ];
          decryption = "none";
        };
        streamSettings = {
          network = "raw";
          security = "reality";
          realitySettings = {
            show = false;
            dest = config.services.caddy.httpsPort;
            serverNames = lib.attrNames config.services.caddy.virtualHosts;
            privateKey._secret = config.age.secrets.reality-private-key.path;
            shortIds = [ "" ];
          };
        };
        tag = "cn-in";
      }
    ];
    outbounds = [
      {
        protocol = "freedom";
        tag = "freedom";
      }
      {
        tag = "jp-out";
        protocol = "vless";
        settings = {
          address = "jp.zaelggk.com";
          port = 443;
          id._secret = config.age.secrets.vless-uuid.path;
          encryption._secret = config.age.secrets.vless-encryption.path;
          flow = "xtls-rprx-vision";
        };
      }
    ];
    routing = {
      rules = [
        {
          domain = [ "geosite:niconico" ];
          inboundTag = [ "cn-in" ];
          outboundTag = "jp-out";
        }
      ];
    };
  };

  age.secrets = {
    reality-private-key.file = config.paths.secrets + "/reality-private-key.age";
    vless-encryption.file = config.paths.secrets + "/vless-encryption.age";
  };
}
