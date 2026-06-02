{ config, lib, ... }:
lib.mkIf config.web-app.enable {

  services.caddy.virtualHosts = {
    "${config.tunnel.subscriptionDomain}.${config.domain}".extraConfig = ''
      basic_auth {
        rag {$HASHED_PASSWORD}
      }
      reverse_proxy 127.0.0.1:${toString config.web-app.port}
    '';
  };

  web-app.subscription.sing-box = {
    configPath = config.tunnel.subscription.sing-box.path;
    urlPath = "sing-box.json";
  };
  web-app.subscription.domain = config.tunnel.subscriptionDomain;

  assertions = [
    {
      assertion = config.services.caddy.enable;
      message = "web-app requires caddy to be enabled";
    }
  ];
}
