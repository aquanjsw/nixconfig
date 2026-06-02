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

    isLimited = lib.mkOption {
      default = false;
      description = "Whether the system is limited in resources.";
    };

    isNixOS = lib.mkOption {
      default = false;
      description = "Whether the system is running NixOS.";
    };

  };

  config = {
    nixpkgs.overlays = [
      inputs.realcugan.overlays.default
    ];
    nixpkgs.config.allowUnfree = true;
  };
}
