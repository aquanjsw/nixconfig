{
  inputs,
  lib,
  ...
}:
{
  options = {

    user = lib.mkOption {
      default = "rag";
      readOnly = true;
    };

    paths = lib.mkOption {
      default = {
        secrets = ./secrets;
      };
      readOnly = true;
    };

    isLimited = lib.mkOption {
      default = false;
      description = "Whether the system is limited in resources.";
    };

  };

  config = {

    nixpkgs.overlays = import ./overlays.nix inputs;
    nixpkgs.config.allowUnfree = true;

  };
}
