# doc: https://github.com/1995chen/dnf
{
  lib,
  config,
  ...
}:
{
  options.dnf.enable = lib.mkEnableOption "DNF server";
  options.dnf.domain = lib.mkOption {
    description = "The domain name for the DNF server.";
  };
  config.virtualisation.oci-containers.containers.dnf = lib.mkIf config.dnf.enable {
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
      "--cpus=1"
      "--memory=1g"
      "--memory-swap=-1"
      "--shm-size=8g"
    ];
    environment = {
      DDNS_ENABLE = "true";
      DDNS_DOMAIN = config.dnf.domain;
      WEB_USER = "rag";
      WEB_PASS = "1";
      DNF_DB_ROOT_PASSWORD = "1";
      GM_ACCOUNT = "rag";
      GM_PASSWORD = "1";
      CLIENT_POOL_SIZE = "3";
    };
  };
}
