{
  lib,
  config,
  ...
}:
let
  user = config.user;
  name = "comfyui";
  root = config.users.users.${user}.home + "/${name}";
in
{
  options.services.comfyui.enable = lib.mkEnableOption "ComfyUI";

  config = lib.mkIf config.services.${name}.enable {
    virtualisation.oci-containers.containers.${name} = {
      image = "yanwk/comfyui-boot:cu130-slim-v2";
      autoStart = false;
      devices = [ "nvidia.com/gpu=all" ];
      podman.user = user;
      ports = [ "8188:8188" ];
      volumes = [
        "${root}/.cache:/root/.cache"
        "${root}/.config:/root/.config"
        "${root}/.local:/root/.local"
        "${root}/custom_nodes:/root/ComfyUI/custom_nodes"
        "${root}/models:/root/ComfyUI/models"
        "${root}/hfhub:/root/.cache/huggingface/hub"
        "${root}/torchhub:/root/.cache/torch/hub"
        "${root}/input:/root/ComfyUI/input"
        "${root}/output:/root/ComfyUI/output"
        "${root}/user:/root/ComfyUI/user"
        "${root}/user-scripts:/root/user-scripts"
      ];
      environment = {
        CLI_ARGS = "";
      };
    };
    systemd.services."podman-${name}".preStart = ''
      mkdir -p ${root}/.cache
      mkdir -p ${root}/.config
      mkdir -p ${root}/.local
      mkdir -p ${root}/custom_nodes
      mkdir -p ${root}/models
      mkdir -p ${root}/hfhub
      mkdir -p ${root}/torchhub
      mkdir -p ${root}/input
      mkdir -p ${root}/output
      mkdir -p ${root}/user
      mkdir -p ${root}/user-scripts
    '';
  };
}
