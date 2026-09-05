{
  lib,
  config,
  pkgs,
  ...
}:
let
  hostname = config.networking.hostName;
  cfg = config.rag.${hostname}.ipv6;
in
{
  options.rag.${hostname}.ipv6 = {
    enable = lib.mkEnableOption "IPv6 support";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ipv6 = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        Restart = "on-failure";
      };
      script = builtins.readFile ./setup-ipv6.sh;
      environment = {
        IP = "${pkgs.iproute2}/bin/ip";
        AWK = "${pkgs.gawk}/bin/awk";
        IPCALC = "${pkgs.ipcalc}/bin/ipcalc";
        PING = "${pkgs.iputils}/bin/ping";
      };
    };
  };
}
