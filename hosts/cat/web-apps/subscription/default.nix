{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.rag.cat.services.web-apps.subscription = {
    enable = lib.mkEnableOption "web-app-subscription";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };
    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "subscription";
    };
  };
  config =
    let
      cfg = config.rag.cat.services.web-apps.subscription;
      pythonEnv = pkgs.python3.withPackages (ps: [
        ps.django
        ps.gunicorn
      ]);
      package = pkgs.stdenv.mkDerivation {
        name = "web-app-subscription";
        src = lib.fileset.toSource {
          root = ./.;
          fileset = lib.fileset.intersection (lib.fileset.unions [
            ./subscription
            ./subalter
          ]) (lib.fileset.gitTracked ./.);
        };
        nativeBuildInputs = [ pkgs.makeWrapper ];
        buildInputs = [ pythonEnv ];
        installPhase = ''
          runHook preInstall

          mkdir -p $out/{bin,lib}
          cp -r subscription subalter $out/lib
          makeWrapper ${pythonEnv}/bin/gunicorn $out/bin/gunicorn --add-flags \
            "--chdir $out/lib -b 127.0.0.1:${toString cfg.port} subscription.wsgi"

          runHook postInstall
        '';
      };
      stolen-server = "www.speedtest.net";
    in
    lib.mkIf cfg.enable {
      rag.utils.json-deployments = {
        sing-box.settings = import config.rag.services.sing-box.client.settings {
          vless-server = config.rag.services.sing-box.server.name;
          vless-uuid = "PLACEHOLDER";
          reality-public-key = {
            _secret = config.age.secrets."by-host/${config.networking.hostName}/reality-public-key".path;
          };
          tailscale-auth-key = {
            _secret = config.age.secrets."by-host/${config.networking.hostName}/tailscale-auth-key".path;
          };
          api-port = config.rag.services.sing-box.client.api-port;
        };
        sing-box-extra.settings = {
          vless-uuids = builtins.listToAttrs (
            map (uuidName: {
              name = uuidName;
              value = {
                _secret = config.age.secrets."by-group/vless-uuids/${uuidName}".path;
              };
            }) (builtins.attrNames config.rag.secret-registry.by-group.vless-uuids)
          );
        };
        sing-box-server.settings = import config.rag.services.sing-box.server.settings {
          vless-uuids = config.rag.services.sing-box.server.vless-uuids;
          server-name = stolen-server;
          handshake-server = stolen-server;
          handshake-port = 443;
          reality-private-key = config.rag.services.sing-box.server.reality-private-key;
          res-password = config.rag.services.sing-box.server.res-password;
          api-port = config.rag.services.sing-box.server.api-port;
          api-secret = config.rag.services.sing-box.server.api-secret;
        };
      };

      services.caddy.virtualHosts = {
        "${cfg.subdomain}.${config.rag.domain}".extraConfig = ''
          basic_auth {
            rag {$HASHED_PASSWORD}
          }
          reverse_proxy 127.0.0.1:${toString cfg.port}
        '';
      };

      systemd.services.web-app-subscription = {
        description = "web-app-subscription";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        environment = {
          SETTINGS_FILE = config.rag.utils.json-deployments.sing-box.path;
          EXTRA_SETTINGS_FILE = config.rag.utils.json-deployments.sing-box-extra.path;
          SERVER_SETTINGS_FILE = config.rag.utils.json-deployments.sing-box-server.path;
          STOLEN_SERVER = stolen-server;
          DOMAIN = "${cfg.subdomain}.${config.rag.domain}";
        };
        script = ''
          ${package}/bin/gunicorn
        '';
        serviceConfig.EnvironmentFile = [
          config.age.secrets."by-host/${config.networking.hostName}/web-app-subscription-env".path
        ];
      };
    };
}
