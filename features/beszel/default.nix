{ config, lib, ... }:
{
  imports = [
    ./agent.nix
    ./hub.nix
  ];

  options.services.beszel.hub.domain = lib.mkOption {
    default = "beszel.${config.domain}";
    readOnly = true;
  };
}
