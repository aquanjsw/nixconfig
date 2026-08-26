{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  rag = {
    services.dnf.enable = true;
    services.dnf.domain = "gecko.${config.rag.domain}";
    programs.rclone.enable = true;
  };

  services.code-server.enable = true;
  services.jellyfin.enable = true;
  services.qbittorrent.enable = true;
  services.samba.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  users.users.${config.rag.username} = {
    packages =
      with pkgs;
      [
        realcugan
        litecli # SQLite CLI Querier
        inputs.agenix.packages.${stdenv.hostPlatform.system}.default
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

  boot.initrd.services.lvm.enable = true;
  fileSystems."/data" = {
    device = lib.mkForce "/dev/bcache0";
    fsType = "xfs";
    options = [ "nofail" ];
  };

  networking.hostName = "dog";

  system.stateVersion = "25.11";
}

# vim: sts=2 sw=2 et ai
