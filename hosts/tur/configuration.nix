{
  hostName,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ./samba.nix
  ];

  isBareMetal = true;

  tunnel.client.enable = true;

  services.beszel.agent.enable = true;
  services.samba.enable = true;
  services.tailscale.enable = true;
  services.ollama.enable = false;
  services.ollama.host = "0.0.0.0";
  services.ollama.package = pkgs.ollama-cuda;

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  nix.settings.substituters = [ "https://cache.nixos-cuda.org" ];
  nix.settings.trusted-public-keys = [
    "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
  ];

  users.users.${config.user} = {
    packages =
      with pkgs;
      [
        litecli
      ]
      ++ (with pkgs.python3Packages; [
        huggingface-hub
      ]);
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostName;

  zramSwap.memoryPercent = 100;
  swapfileSize = 8 * 1024;

  fileSystems = {
    "/data" = {
      device = "/dev/disk/by-id/ata-WDC_WD4002FYYZ-01B7CB0_N8G9ZA7Y";
      fsType = "ext4";
      options = [ "nofail" ];
    };
    "/oldhome" = {
      device = "/dev/disk/by-id/ata-WDC_WD4002FYYZ-01B7CB0_N8G9WA6Y-part1";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    ollama-cuda = pkgs.ollama-cuda.override {
      cudaArches = [ "61" ];
    };
  };

  nixpkgs.config.cudaSupport = true;

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
