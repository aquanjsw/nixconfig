{
  description = "Rag's Nix Config";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

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

      hosts = [
        "cat"
        "dog"
        "dodo"
        "panda"
      ];

      mkNixOS =
        host:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            inputs.disko.nixosModules.disko
            inputs.agenix.nixosModules.default
            inputs.web-app.nixosModules.default
            inputs.nixos-wsl.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
            ./nixCommon.nix
            ./nixosCommon
            (
              { config, ... }:
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = {
                  inherit inputs;
                  args = {
                    inherit (config) user isLimited;
                    isNixOS = true;
                  };
                };
                home-manager.users.${config.user} = ./home;
              }
            )
            ./mods
            ./hosts/${host}/configuration.nix
          ];
        };

      mkHome =
        system:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = {
            inherit inputs;
            args = {
              isNixOS = false;
            };
          };
          modules = [
            ./nixCommon.nix
            ./home
          ];
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hosts (host: mkNixOS host);

      homeConfigurations = {
        agx = mkHome "aarch64-linux";
      };
    };
}

# vim: sts=2 sw=2 et ai
