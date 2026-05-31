{
  config,
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

    isNixOS = lib.mkOption {
      default = false;
      description = "Whether the system is running NixOS.";
    };

  };

  config = lib.mkMerge [

    (lib.mkIf config.isNixOS {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit inputs;
        args = { inherit (config) user isLimited isNixOS; };
      };
      home-manager.users.${config.user} = ./home;
    })

    {
      nixpkgs.overlays = import ./overlays.nix inputs;
      nixpkgs.config.allowUnfree = true;
    }

  ];
}
