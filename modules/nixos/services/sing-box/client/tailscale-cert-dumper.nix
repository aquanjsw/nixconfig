{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.rag.services.sing-box;
  runtimeDirectory = "tailscale-cert";
  domain = config.rag.magicDNS;
  certFile = "/run/${runtimeDirectory}/${domain}.crt";
  keyFile = "/run/${runtimeDirectory}/${domain}.key";
in
{
  options.rag.services.sing-box.client.tailscaleCertDumper.enable =
    lib.mkEnableOption "tailscale cert dumper";

  config = lib.mkIf cfg.client.tailscaleCertDumper.enable {
    systemd.services."sing-box-tailscale-cert-dumper" = {
      description = "Sing-Box Tailscale Cert Dumper";
      wantedBy = [ "sing-box.service" ];
      after = [ "sing-box.service" ];
      serviceConfig = {
        Type = "oneshot";
        RuntimeDirectory = runtimeDirectory;
        RuntimeDirectoryPreserve = true;
      };
      environment = {
        BOX_API_URL = "http://127.0.0.1:${toString cfg.api-port}";
        SING_BOX = "${pkgs.sing-box}/bin/sing-box";
        DOMAIN = domain;
        CERT_FILE = certFile;
        KEY_FILE = keyFile;
      };
      script = builtins.readFile ./tailscale-cert-dumper.sh;
    };
    environment.sessionVariables = {
      TS_CERT = certFile;
      TS_KEY = keyFile;
    };
  };
}
