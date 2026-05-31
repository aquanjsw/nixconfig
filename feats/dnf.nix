{
  lib,
  config,
  ...
}:
{
  options.feats.dnf.enable = lib.mkEnableOption "DNF server";
  config = lib.mkIf config.feats.dnf.enable {
    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        dnf = {
          image = "1995chen/dnf:centos7-2.1.9.fix1";
          autoStart = true;
          volumes = [
            "dnf-log:/home/neople/game/log:Z"
            "dnf-mysql:/var/lib/mysql:Z"
            "dnf-data:/data:Z"
          ];
          ports = [
            "2000:180"
            "3000:3306/tcp"
            "7600:7600/tcp"
            "881:881/tcp"
            "7001:7001/tcp"
            "7001:7001/udp"
            "30011:30011/tcp"
            "31011:31011/udp"
            "30052:30052/tcp"
            "31052:31052/udp"
            "7300:7300/tcp"
            "7300:7300/udp"
            "2311-2313:2311-2313/udp"
          ];
          extraOptions = [
            "--cap-add=NET_ADMIN"
            "--hostname=dnf"
            "--cpus=2"
            "--memory=5g"
            "--memory-swap=-1"
            "--shm-size=8g"
          ];
          environment = {
            # PUBLIC_IP = "0.0.0.0";
            DDNS_ENABLE = "true";
            DDNS_DOMAIN = "gecko.${config.domain}";
            WEB_USER = "rag";
            WEB_PASS = "1";
            DNF_DB_ROOT_PASSWORD = "1";
            GM_ACCOUNT = "rag";
            GM_PASSWORD = "1";
            CLIENT_POOL_SIZE = "3";
          };
        };
      };
    };
    assertions = [
      {
        assertion = config.virtualisation.podman.enable;
        message = "DNF server requires podman to be enabled";
      }
    ];
  };
}
