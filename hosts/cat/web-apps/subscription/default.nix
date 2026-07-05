{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.services.web-app.subscription.enable = lib.mkEnableOption "web-app-subscription";
  options.services.web-app.subscription.port = lib.mkOption {
    type = lib.types.port;
    default = 8080;
  };
  options.services.web-app.subscription.domain = lib.mkOption {
    type = lib.types.str;
    default = "subscription";
  };
  config =
    let
      cfg = config.services.web-app.subscription;
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
    lib.mkIf cfg.enable {
      jsonDeployment.deployments.sing-box.settings = config.tunnel.client.settings;
      jsonDeployment.deployments.sing-box-extra.settings = {
        tailscale-auth-key._secret = config.age.secrets.tailscale-auth-key.path;
      };
      services.caddy.virtualHosts = {
        "${cfg.domain}.${config.domain}".extraConfig = ''
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
          SETTINGS_FILE = config.jsonDeployment.deployments.sing-box.path;
          EXTRA_SETTINGS_FILE = config.jsonDeployment.deployments.sing-box-extra.path;
          DOMAIN = "${cfg.domain}.${config.domain}";
        };
        script = ''
          ${package}/bin/gunicorn
        '';
        serviceConfig.environmentFile = [
          config.age.secrets.web-app-subscription-env.path
        ];
      };
      age.secrets.web-app-subscription-env.file = config.paths.secrets + "/web-app-subscription-env.age";
      age.secrets.tailscale-auth-key.file = config.paths.secrets + "/tailscale-auth-key.age";
    };
}
