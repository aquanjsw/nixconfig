{ config, lib, ... }:
{
  config = lib.mkIf config.services.openssh.enable {
    services.openssh.settings.PasswordAuthentication = false;
    systemd.services.sshd.serviceConfig = {
      OOMScoreAdjust = -1000;
    };
  };
}
