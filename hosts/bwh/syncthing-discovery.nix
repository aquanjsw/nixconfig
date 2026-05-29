{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.services.syncthing.discovery = {
    enable = lib.mkEnableOption "syncthing dicovery server";
    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 8443;
    };
    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };

  config =
    let
      cfg = config.services.syncthing.discovery;
      stateDir = "/var/lib/stdiscosrv";
      srvOptions = [
        "--http"
        "--listen=${cfg.listenAddress}:${toString cfg.listenPort}"
        "--db-dir=${stateDir}"
      ];
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.syncthing-discovery ];

      services.syncthing.discovery.listenAddress = "127.0.0.1";

      systemd.services.stdiscosrv = {
        description = "Syncthing Discovery Server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          DynamicUser = true;
          StateDirectory = baseNameOf stateDir;
          Restart = "on-failure";
          ExecStart = "${lib.getExe pkgs.syncthing-discovery} ${lib.concatStringsSep " " srvOptions}";
        };
      };

      services.caddy.virtualHosts."discovery.${config.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.listenPort} {
          header_up X-Forwarded-For {http.request.remote.host}
          header_up X-Client-Port {http.request.remote.port}
          header_up X-Tls-Client-Cert-Der-Base64 {http.request.tls.client.certificate_der_base64}
          header_up -X-Ssl-Cert
          header_up -X-Forwarded-Tls-Client-Cert
        }

        tls {
          client_auth {
            mode request
          }
        }
      '';

      assertions = [
        {
          assertion = config.services.caddy.enable;
          message = "syncthing discovery server requires caddy to be enabled";
        }
      ];
    };
}
