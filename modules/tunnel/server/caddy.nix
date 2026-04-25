{ 
  utils,
  config,
  pkgs,
  lib,
  ...
}: {

  options = {
    caddy = {
      baseDomain = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      extraConfig = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      httpsPort = lib.mkOption {
        type = lib.types.int;
        default = 1443;
      };
    };
  };

  config = lib.mkIf config.tunnel.server.enable {

    age.secrets.caddy-env = { file = config.paths.secrets + "/caddy-env.age"; };

    services.caddy = {
      enable = true;
      environmentFile = config.age.secrets.caddy-env.path;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
        hash = "sha256-Olz4W84Kiyldy+JtbIicVCL7dAYl4zq+2rxEOUTObxA=";
      };
      extraConfig = ''
        ${config.caddy.baseDomain} {
          root * ${config.services.caddy.dataDir}
          file_server
        }
      '' + config.caddy.extraConfig;
      globalConfig = ''
        http_port 2080
        https_port ${builtins.toString config.caddy.httpsPort}
        default_bind 127.0.0.1
        acme_dns cloudflare {$CF_API_TOKEN}
      '';
    };

    systemd.services.generateSubscription = {
      description = "Generate Tunnel Client Subscription";
      after = [ "caddy.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = let 
          script = pkgs.writeShellScript "gen-tunnel-client-config" ''
            ${utils.genJqSecretsReplacementSnippet
              config.tunnel.client.config
              "${config.services.caddy.dataDir}/config.json"}
            chown --reference="${config.services.caddy.dataDir}" \
              "${config.services.caddy.dataDir}/config.json"
          '';
        in "+${script}";
      };
    };
  };
}