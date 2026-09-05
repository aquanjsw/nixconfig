{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.rag.utils.dns-record-syncer;
in
{
  options.rag.utils.dns-record-syncer = {
    enable = lib.mkEnableOption "a systemd one-shot service on startup that syncs local IP to DNS record";
    domain = lib.mkOption {
      default = config.rag.domain;
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.dns-record-syncer = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      description = "Syncs local IP to DNS record";
      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile =
          config.age.secrets."by-host/${config.networking.hostName}/cloudflare-api-token-env".path;
      };
      script = builtins.readFile ./sync.sh;
      environment = {
        DOMAIN = cfg.domain;
        ZONE_ID = "93b98e5d2505428a7bda13476f8b179d";
        IP = "${pkgs.iproute2}/bin/ip";
        AWK = "${pkgs.gawk}/bin/awk";
        JQ = "${pkgs.jq}/bin/jq";
        CURL = "${pkgs.curl}/bin/curl";
        IPCALC = "${pkgs.ipcalc}/bin/ipcalc";
        CLOUDFLARE = config.rag.utils.scripts.cloudflare;
      };
    };
  };
}
