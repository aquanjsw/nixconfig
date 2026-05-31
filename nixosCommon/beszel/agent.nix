{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf config.services.beszel.agent.enable {

  services.beszel.agent = {
    environmentFile = config.age.secrets.beszel-agent-env.path;
    environment = {
      HUB_URL = "https://beszel.${config.domain}";
    };
  };

  environment.systemPackages = lib.optional config.isBareMetal pkgs.smartmontools;

  systemd.services.beszel-agent = {
    serviceConfig = {
      PrivateDevices = lib.mkForce false; # nvidia monitoring
    };
  };

  age.secrets.beszel-agent-env.file = config.paths.secrets + "/beszel-agent-env.age";
}
