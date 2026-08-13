{
  description = "Shin Rag's nixconfig";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    realcugan.url = "github:aquanjsw/realcugan";
    realcugan.inputs.nixpkgs.follows = "nixpkgs";

    ssh-keys.url = "https://github.com/aquanjsw.keys";
    ssh-keys.flake = false;
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      mkNixOS =
        hostname:
        (lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./modules/home
            ./modules/nixos
            ./hosts/${hostname}/configuration.nix
          ];
        });

      forAllSystems = lib.genAttrs lib.systems.flakeExposed;

      hostnames = [
        "dog"
        "cat"
        "tur"
      ];
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hostnames (hostname: mkNixOS hostname);

      devShells = forAllSystems (
        system:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
          utils = import "${inputs.nixpkgs}/nixos/lib/utils.nix" {
            inherit pkgs lib;
          };
        in
        (import ./devShells.nix { inherit pkgs utils lib; })
      );
    };
}

# vim: sts=2 sw=2 et ai
