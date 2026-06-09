{
  config,
  lib,
  ...
}:
{
  options.services.freellmapi.enable = lib.mkEnableOption "FreeLLM API server";
  options.services.freellmapi.port = lib.mkOption {
    type = lib.types.port;
    default = 3001;
  };
  config = lib.mkIf config.services.freellmapi.enable {
    virtualisation.oci-containers.containers."freellmapi" = {
      image = "ghcr.io/tashfeenahmed/freellmapi:latest";
      autoStart = true;
      environment = {
        NODE_ENV = "production";
        PORT = "3001";
      };
      environmentFiles = [
        config.age.secrets.freellmapi.path
      ];
      volumes = [
        "freellmapi-data:/app/server/data:rw"
      ];
      ports = [
        "0.0.0.0:${toString config.services.freellmapi.port}:3001/tcp"
      ];
    };
    age.secrets.freellmapi.file = config.paths.secrets + "/freellmapi.age";
  };
}
