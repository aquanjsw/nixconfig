{
  config,
  lib,
  pkgs,
  ...
}:
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
in
{
  options.rag.cat.services.web-apps.subscription = {
    enable = lib.mkEnableOption "web-app-subscription";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "subscription.${config.rag.domain}";
    };
  };
  config = lib.mkIf cfg.enable {
    rag.utils.json-deployments = {
      sing-box.settings = import config.rag.services.sing-box.client.settings {
        server = config.rag.services.sing-box.server.domain;
        uuid = "PLACEHOLDER";
        reality-public-key = {
          _secret = config.sops.secrets."sing-box/reality/public-key".path;
        };
        ts-auth-key = {
          _secret = config.sops.secrets."ts-auth-key".path;
        };
        api-port = config.rag.services.sing-box.api-port;
      };
      sing-box-extra.settings = {
        uuids = map (uuidName: {
          _secret = config.sops.secrets."sing-box/uuids/${uuidName}".path;
        }) config.rag.services.sing-box.server.uuidNames;
      };
    };

    services.caddy.virtualHosts = {
      "${cfg.domain}".extraConfig = ''
        basic_auth {
          rag {$HASHED_PASSWD}
        }
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };

    sops.templates."web-app-subscription.env".content = ''
      DJANGO_KEY=${config.sops.placeholder.django-key}
    '';

    systemd.services.web-app-subscription = {
      description = "web-app-subscription";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment = {
        SETTINGS_FILE = config.rag.utils.json-deployments.sing-box.path;
        EXTRA_SETTINGS_FILE = config.rag.utils.json-deployments.sing-box-extra.path;
        DOMAIN = cfg.domain;
      };
      script = ''
        ${package}/bin/gunicorn
      '';
      serviceConfig.EnvironmentFile = [
        config.sops.templates."web-app-subscription.env".path
      ];
    };
  };
}
