{ config, lib, ... }:
lib.mkIf config.web-app.enable (
  let
    subscriptionDomain = "subscription";
  in
  {
    services.caddy.virtualHosts = {
      "${subscriptionDomain}.${config.domain}".extraConfig = ''
        basic_auth {
          rag {$HASHED_PASSWORD}
        }
        reverse_proxy 127.0.0.1:${toString config.web-app.port}
      '';
    };
    jsonDeployment.deployments.sing-box.settings = config.tunnel.client.settings;
    web-app.subscription.sing-box = {
      configPath = config.jsonDeployment.deployments.sing-box.path;
      urlPath = "sing-box.json";
    };
    web-app.subscription.domain = subscriptionDomain;
  }
)
