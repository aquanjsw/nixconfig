{
  disabledModules = [
    "services/networking/xray.nix"
    "services/networking/mihomo.nix"
  ];

  imports = [
    ./xray.nix
    ./mihomo.nix
  ];
}