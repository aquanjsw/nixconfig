{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ./openwrt
  ];

  rag = {
    services.openwrt.enable = true;
  };

  networking = {
    interfaces = {
      tap0 = {
        virtual = true;
        virtualType = "tap";
      };
      tap1 = {
        virtual = true;
        virtualType = "tap";
      };
      br0 = {
        ipv4.addresses = [
          {
            address = "192.168.1.1";
            prefixLength = 24;
          }
        ];
        useDHCP = true;
      };
    };
    bridges = {
      br0.interfaces = [
        "enp3s0"
        "tap0"
      ];
      br1.interfaces = [
        "enp1s0"
        "tap1"
      ];
    };
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
    socat
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
