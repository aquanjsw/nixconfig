{
  pkgs,
  config,
  lib,
  ...
}:
let
  user = config.user;
  name = "kohya-ss";
  root = config.users.users.${user}.home + "/${name}";
in
{
  options.services.kohya-ss.enable = lib.mkEnableOption "kohya-ss";
  options.services.kohya-ss.port = lib.mkOption {
    type = lib.types.port;
    default = 7860;
  };
  options.services.kohya-ss.tensorboardPort = lib.mkOption {
    type = lib.types.port;
    default = 6006;
  };

  config =
    let
      cfg = config.services.${name};
    in
    lib.mkIf cfg.enable {
      virtualisation.oci-containers.containers.${name} = {
        image = "ghcr.io/bmaltais/kohya-ss-gui:v25.2.1";
        autoStart = false;
        devices = [ "nvidia.com/gpu=all" ];
        podman.user = user;
        ports = [ "${toString cfg.port}:7860" ];
        environment = {
          SAFETENSORS_FAST_GPU = "1";
          TENSORBOARD_PORT = "${toString cfg.tensorboardPort}";
        };
        environmentFiles = [ config.age.secrets.huggingface-env.path ];
        extraOptions = [ "--tmpfs=/tmp" ];
        user = "1000:0";
        volumes = [
          "${root}/models:/app/models"
          "${root}/datasets:/datasets"
          "${root}/images:/app/data"
          "${root}/logs:/app/logs"
          "${root}/outputs:/app/outputs"
          "${root}/regularization:/app/regularization"
          "${root}/.cache/config:/app/config"
          "${root}/.cache/user:/home/1000/.cache"
          "${root}/.cache/triton:/home/1000/.triton"
          "${root}/.cache/nv:/home/1000/.nv"
          "${root}/.cache/keras:/home/1000/.keras"
          "${root}/hfhub:/home/1000/.cache/huggingface/hub"
        ];
      };
      systemd.services."podman-${name}".preStart = ''
        mkdir -p ${root}/models
        mkdir -p ${root}/datasets
        mkdir -p ${root}/images
        mkdir -p ${root}/logs
        mkdir -p ${root}/outputs
        mkdir -p ${root}/regularization
        mkdir -p ${root}/.cache/config
        mkdir -p ${root}/.cache/user
        mkdir -p ${root}/.cache/triton
        mkdir -p ${root}/.cache/nv
        mkdir -p ${root}/.cache/keras
        mkdir -p ${root}/hfhub
      '';
      systemd.services."tensorboard-${name}" = {
        wantedBy = [ "podman-${name}.service" ];
        script = ''
          ${lib.getExe pkgs.python3Packages.tensorboard} --logdir ${root}/logs  --bind_all --port ${toString cfg.tensorboardPort}
        '';
        serviceConfig = {
          User = "${user}";
        };
      };
    };
}
