{
  description = "Rag's NixOS Flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    ssh-keys.url = "https://github.com/aquanjsw.keys";
    ssh-keys.flake = false;
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    agenix,
    disko,
    ...
  }:
  let
    globalModule = {
      config,
      inputs,
      lib,
      ...
    }:
    {
      disabledModules = [
        "services/networking/xray.nix"
      ];
      imports = [
        inputs.agenix.nixosModules.default
        ./services/networking/xray.nix
      ];
      options = {
        paths = lib.mkOption {
          type = lib.types.attrsOf lib.types.path;
          default = {
            modules = ./modules;
            secrets = ./secrets;
          };
        };
      };
      config = let 
        secrets = config.paths.secrets;
      in {
        age.secrets = {
          vless-uuid = { file = secrets + "/vless-uuid.age"; };
          reality-private-key = { file = secrets + "/reality-private-key.age"; };
          vultr-domain = { file = secrets + "/vultr-domain.age"; };
          reality-public-key = { file = secrets + "/reality-public-key.age"; };
          clash-api-secret = { file = secrets + "/clash-api-secret.age"; };
          rootDomain = { file = secrets + "/rootDomain.age"; };
          bwh-domain = { file = secrets + "/bwh-domain.age"; };
          domain = { file = secrets + "/domain.age"; };
        };
      };
    };
  in
  {
    nixosConfigurations = {

      minimal = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          globalModule
          ./modules/common
          ./modules/tunnel
          ./hosts/minimal/configuration.nix
        ];
      };

      bwh = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          globalModule
          ./modules/common
          ./modules/tunnel
          ./hosts/bwh/configuration.nix
        ];
      };

      vultr = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          globalModule
          ./modules/common
          ./modules/tunnel
          ./hosts/vultr/configuration.nix
        ];
      };
    };
  };
}

# vim: sts=2 sw=2 et ai
