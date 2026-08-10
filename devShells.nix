{ inputs }:
system: {
  web-app-subscription =
    let
      pkgs = import inputs.nixpkgs { inherit system; };
      inherit (pkgs) lib;
      utils = import "${inputs.nixpkgs}/nixos/lib/utils.nix" {
        inherit pkgs lib;
        config = { };
      };
      pythonEnv = pkgs.python3.withPackages (ps: [ ps.django ]);
      settings = import ./features/tunnel/client/settings.nix {
        vless-server = "example.com";
        vless-uuid = "dummy-secret";
        reality-pubkey = "dummy-secret";
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
        ln -sf ${lib.getBin pythonEnv}/bin/python .dev/python
        ${utils.genJqSecretsReplacementSnippet settings settingsFile}
        echo '${builtins.toJSON extraSettings}' > ${extraSettingsFile}
      '';
      SETTINGS_FILE = settingsFile;
      EXTRA_SETTINGS_FILE = extraSettingsFile;
      DEBUG = 1;
    };
}
