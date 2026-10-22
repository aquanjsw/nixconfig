{
  config,
  lib,
  pkgs,
  ...
}:
let
  domain = config.rag.domain;
in
{
  config = lib.mkIf (config.services.caddy.enable && config.rag.services.sing-box.role == "client") {
    systemd.services.tailnetip2cloudflare = {
      description = "Sync tailnet IP with Cloudflare DNS";
      wants = [
        "sing-box.service"
        "network-online.target"
      ];
      after = [
        "sing-box.service"
        "network-online.target"
      ];
      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = config.sops.templates."cf.env".path;
      };
      environment = {
        BOX_API_URL = "http://127.0.0.1:${toString config.rag.services.sing-box.api-port}";
        HOSTNAME = config.networking.hostName;
        DOMAIN = domain;
        ZONE_ID = "93b98e5d2505428a7bda13476f8b179d";
        SING_BOX = "${pkgs.sing-box}/bin/sing-box";
        AWK = "${pkgs.gawk}/bin/awk";
        TR = "${pkgs.coreutils}/bin/tr";
        JQ = "${pkgs.jq}/bin/jq";
        CURL = "${pkgs.curl}/bin/curl";
        CLOUDFLARE = config.rag.utils.scripts.cloudflare;
      };
      script = builtins.readFile ./cloudflare.sh;
    };

    services.caddy = {
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
        hash = "sha256-xRJ5evsAJ2akg47j3Bt6YDXJOgX88B/rKNP50KSVyNY=";
      };
      environmentFile = config.sops.templates."cf.env".path;
      globalConfig = ''
        acme_dns cloudflare {$CF_API_TOKEN}
      '';
      virtualHosts."${domain}".extraConfig = ''
        respond "Hello, World!"
      '';
    };

    systemd.services.caddy = {
      wants = [ "tailnetip2cloudflare.service" ];
      after = [ "tailnetip2cloudflare.service" ];
    };
  };
}
