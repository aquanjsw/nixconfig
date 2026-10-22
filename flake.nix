{
  description = "Shin Rag's nixconfig";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    ragixpkgs.url = "github:aquanjsw/ragixpkgs";
    ragixpkgs.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    realcugan.url = "github:aquanjsw/realcugan";

    demos.url = "github:aquanjsw/demos";

    ssh-keys.url = "https://github.com/aquanjsw.keys";
    ssh-keys.flake = false;
  };

  outputs =
    inputs@{
      nixpkgs,
      self,
      deploy-rs,
      sops-nix,
      disko,
      home-manager,
      demos,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      inherit (builtins) mapAttrs;
      mkNixOS =
        hostName: hostAttrs:
        let
          pkgs-unstable = import inputs.nixpkgs-unstable {
            system = hostAttrs.system;
            config.allowUnfree = true;
            overlays = import ./overlays.nix { inherit inputs; };
          };
        in
        (lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              self
              pkgs-unstable
              ;
          };
          modules = [
            ./modules/home
            ./modules/nixos
            ./hosts/${hostName}/configuration.nix
            sops-nix.nixosModules.sops
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            demos.nixosModules.default
            {
              networking.hostName = hostName;
            }
          ];
        });
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
      hostRegistry = {
        dog = { };
        cat = { };
        tur = { };
        bun = { };
        rac = { };
      };
      hosts = mapAttrs (
        hostName: hostAttrs:
        {
          system = "x86_64-linux";
        }
        // hostRegistry.${hostName}
      ) hostRegistry;
    in
    {
      nixosConfigurations = mapAttrs mkNixOS hosts;
      deploy.nodes = mapAttrs (hostName: hostAttrs: {
        hostname = hostName;
        profiles.system = {
          sshUser = "root";
          path = deploy-rs.lib.${hostAttrs.system}.activate.nixos self.nixosConfigurations.${hostName};
        };
      }) hosts;
      checks = mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
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
