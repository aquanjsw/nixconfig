{
  lib,
  ...
}: {

  disabledModules = [
    "services/networking/xray.nix"
  ];

  imports = [
    ./official-xray-modified.nix
    ./caddy.nix
    ./xray.nix
  ];

  options.tunnel.server.enable = lib.mkEnableOption "tunnel server";
}