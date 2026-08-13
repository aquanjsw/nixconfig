{ config, lib, ... }:
{
  config = lib.mkIf (builtins.elem "nvidia" config.services.xserver.videoDrivers) {
    hardware.nvidia-container-toolkit.enable = true;
    hardware.graphics.enable = true;
    hardware.nvidia.open = lib.mkDefault true;
    nix.settings.substituters = [ "https://cache.nixos-cuda.org" ];
    nix.settings.trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
    nixpkgs.config.cudaSupport = true;
  };
}
