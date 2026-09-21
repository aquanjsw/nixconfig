{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  rag = {
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.systemPackages = with pkgs; [
    binutils # nm
    usbutils # lsusb
    pciutils # lspci
    inputs.agenix.packages.${stdenv.hostPlatform.system}.default
    ruff
    ty
    deploy-rs
    firefox
    niri
    fuzzel
    ghostty
    xdg-utils
  ];

  boot.loader.systemd-boot.enable = true;

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
