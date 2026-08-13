{
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./utils
    ./data
    ./services
    ./system
    ./user
    ./overlays
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
  ];

  options.rag = {
    domain = lib.mkOption {
      default = "zaelggk.com";
      readOnly = true;
    };
    username = lib.mkOption {
      default = "rag";
      readOnly = true;
    };
    secret-registry = lib.mkOption {
      default = import ../../secret-registry.nix { inherit lib; };
      readOnly = true;
    };
    ssh-keys = lib.mkOption {
      default = lib.strings.splitString "\n" (lib.strings.trim (builtins.readFile inputs.ssh-keys));
      readOnly = true;
    };
  };
}
