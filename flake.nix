{
  description = "Rag's Nix Config";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    i915-sriov.url = "github:strongtz/i915-sriov-dkms";
    i915-sriov.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    realcugan.url = "github:aquanjsw/realcugan";
    realcugan.inputs.nixpkgs.follows = "nixpkgs";

    ssh-keys.url = "https://github.com/aquanjsw.keys";
    ssh-keys.flake = false;

    web-app.url = ./flakes/web-app;
    web-app.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let

      oses = [
        "cat"
        "dog"
      ];

      hms = [
        "agx"
      ];

      mkOs =
        hostName:
        (nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            (
              { lib, config, ... }:
              {
                options = {
                  paths = lib.mkOption {
                    default = {
                      secrets = ./secrets;
                    };
                    readOnly = true;
                  };
                };
                config = {
                  home-manager.users.${config.user} = ./hm/hosts/${hostName};
                };
              }
            )
            inputs.disko.nixosModules.disko
            inputs.agenix.nixosModules.default
            inputs.web-app.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            inputs.i915-sriov.nixosModules.default
            ./features
            ./substitutes
            ./hosts/${hostName}/configuration.nix
          ];
        });

      mkHm =
        hostName:
        inputs.home-manager.lib.homeManagerConfiguration {
          modules = [
            ./hm/hosts/${hostName}
          ];
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs oses (hostName: mkOs hostName);
      homeConfigurations = nixpkgs.lib.genAttrs hms (hostName: mkHm hostName);
    };
}

# vim: sts=2 sw=2 et ai
