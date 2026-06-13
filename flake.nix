{
  description = "Rag's Nix Config";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-latest.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

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

      hosts.cat.system = "x86_64-linux";
      hosts.dog.system = "x86_64-linux";

      mkNixOS =
        hostName:
        (
          let
            system = hosts.${hostName}.system;
            pkgs-latest = import inputs.nixpkgs-latest {
              inherit system;
              config.allowUnfree = true;
            };
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs pkgs-latest; };
            modules = [
              (
                { config, ... }:
                {
                  isNixOS = true;
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.extraSpecialArgs = {
                    inherit inputs;
                    args = { inherit (config) user isLimited isNixOS; };
                  };
                  home-manager.users.${config.user} = ./home.nix;
                }
              )
              inputs.disko.nixosModules.disko
              inputs.agenix.nixosModules.default
              inputs.web-app.nixosModules.default
              inputs.nixos-wsl.nixosModules.default
              inputs.home-manager.nixosModules.home-manager
              inputs.i915-sriov.nixosModules.default
              ./common.nix
              ./features
              ./substitutes
              ./hosts/${hostName}/configuration.nix
            ];
          }
        );

      mkHome =
        system:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs; };
          modules = [
            {
              isNixOS = false;
            }
            ./common.nix
            ./home.nix
          ];
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames hosts) (
        hostName: mkNixOS hostName
      );

      homeConfigurations = {
        agx = mkHome "aarch64-linux";
      };
    };
}

# vim: sts=2 sw=2 et ai
