{
  config,
  inputs,
  lib,
  pkgs,
  self,
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
    ./programs
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.demos.nixosModules.default
  ];

  options.rag = {
    magicDNS = lib.mkOption {
      default = "${config.networking.hostName}.tail2fa86.ts.net";
    };
    email = lib.mkOption {
      default = "zhdlcc@gmail.com";
      readOnly = true;
    };
    rootDomain = lib.mkOption {
      default = "zaelggk.com";
      readOnly = true;
    };
    domain = lib.mkOption {
      default = "${config.networking.hostName}.${config.rag.rootDomain}";
    };
    username = lib.mkOption {
      default = "rag";
      readOnly = true;
    };
    secret-registry = lib.mkOption {
      default = pkgs.callPackage "${self}/secret-registry.nix" { };
      readOnly = true;
    };
    ssh-keys = lib.mkOption {
      default = lib.strings.splitString "\n" (lib.strings.trim (builtins.readFile inputs.ssh-keys));
      readOnly = true;
    };
  };
}
