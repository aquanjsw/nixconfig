{
  description = "Shin Rag's nixconfig";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    realcugan.url = "github:aquanjsw/realcugan";
    realcugan.inputs.nixpkgs.follows = "nixpkgs";

    demos.url = "github:aquanjsw/demos";
    demos.inputs.nixpkgs.follows = "nixpkgs";

    ssh-keys.url = "https://github.com/aquanjsw.keys";
    ssh-keys.flake = false;
  };

  outputs =
    inputs@{
      nixpkgs,
      self,
      deploy-rs,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      mkNixOS =
        hostname:
        (lib.nixosSystem {
          specialArgs = { inherit inputs self; };
          modules = [
            ./modules/home
            ./modules/nixos
            ./hosts/${hostname}/configuration.nix
          ];
        });
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
      hosts = {
        dog = "x86_64-linux";
        cat = "x86_64-linux";
        tur = "x86_64-linux";
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs (builtins.attrNames hosts) (hostname: mkNixOS hostname);
      deploy.nodes = builtins.mapAttrs (hostname: arch: {
        inherit hostname;
        profiles.system = {
          sshUser = "root";
          path = deploy-rs.lib.${arch}.activate.nixos self.nixosConfigurations.${hostname};
        };
      }) hosts;
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = import ./overlays.nix { inherit inputs; };
          };
          inherit (pkgs) lib;
          utils = pkgs.callPackage "${nixpkgs}/nixos/lib/utils.nix" { };
        in
        import ./devshells {
          inherit
            self
            utils
            pkgs
            lib
            ;
        }
      );
    };
}

# vim: sts=2 sw=2 et ai
