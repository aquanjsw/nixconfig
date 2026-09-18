{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  rag = {
  };

  networking = {
    interfaces.tap0 = {
      virtual = true;
      virtualType = "tap";
    };
    bridges.br0.interfaces = [
      "enp3s0"
      "tap0"
    ];
  };

  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  environment.systemPackages = with pkgs; [
    pciutils
    deploy-rs
    qemu_kvm
    OVMF
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
