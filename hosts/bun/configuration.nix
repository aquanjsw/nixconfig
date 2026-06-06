{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ./gpu
  ];

  gpu.sriov = true;

  isBareMetal = true;

  services.sing-box.enable = true;
  services.beszel.agent.enable = true;

  hardware.graphics.enable = false;

  users.users.${config.user} = {
    packages = with pkgs; [
    ];
  };

  environment.systemPackages = with pkgs; [
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "bun";
  networking.bridges.br0.interfaces = [
    "enp3s0"
    "tap0"
  ];

  networking.interfaces.enp3s0.useDHCP = false;
  networking.interfaces.br0.useDHCP = true;
  networking.interfaces.tap0 = {
    useDHCP = false;
    virtual = true;
  };

  system.stateVersion = "26.05";
}

# vim: sts=2 sw=2 et ai
