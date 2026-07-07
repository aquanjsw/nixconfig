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
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      oses = [
        "cat"
        "dog"
        "bun"
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

      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs oses (hostName: mkOs hostName);
      homeConfigurations = nixpkgs.lib.genAttrs hms (hostName: mkHm hostName);

      devShells = forAllSystems (system: {
        web-app-subscription =
          let
            pkgs = import nixpkgs { inherit system; };
            utils = import "${nixpkgs}/nixos/lib/utils.nix" {
              inherit pkgs;
              inherit (pkgs) lib;
              config = { };
            };
            pythonEnv = pkgs.python3.withPackages (ps: [ ps.django ]);
            dummySecretFile = "/tmp/dummy-secret";
            settings = import ./features/tunnel/client/settings.nix {
              config = {
                domain = "example.com";
                age.secrets.vless-uuid.path = dummySecretFile;
                age.secrets.reality-public-key.path = dummySecretFile;
              };
            };
            settingsFile = "/tmp/config.json";
            extraSettings = {
              tailscale-auth-key = "test key";
            };
            extraSettingsFile = "/tmp/extra-config.json";
          in
          pkgs.mkShellNoCC {
            packages = [ pythonEnv ];
            shellHook = ''
              mkdir -p .dev
              echo "dummy secret" > ${dummySecretFile}
              ln -sf ${lib.getBin pythonEnv}/bin/python .dev/python
              ${utils.genJqSecretsReplacementSnippet settings settingsFile}
              echo '${builtins.toJSON extraSettings}' > ${extraSettingsFile}
            '';
            SETTINGS_FILE = settingsFile;
            EXTRA_SETTINGS_FILE = extraSettingsFile;
            DEBUG = 1;
          };
      });
    };
}

# vim: sts=2 sw=2 et ai
