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

  services.samba.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

  users.users.${config.rag.username} = {
    packages =
      with pkgs;
      [
        # Python LSP for Zed
        ruff
        ty
      ]
      ++ (with pkgs.python3Packages; [
        huggingface-hub
      ]);
  };

  environment.systemPackages = with pkgs; [
    binutils # nm
    usbutils # lsusb
    pciutils # lspci
  ];

  boot.loader.systemd-boot.enable = true;

  networking.hostName = "tur";

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

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
