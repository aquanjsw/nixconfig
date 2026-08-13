{
  pkgs,
  lib,
  ...
}:
{
  web-app-subscription =
    let
      pythonEnv = pkgs.python3.withPackages (ps: [ ps.django ]);
      settings = import ./modules/nixos/services/sing-box/client/settings.nix {
        vless-server = "PLACEHOLDER";
        vless-uuid = "PLACEHOLDER";
        reality-public-key = "PLACEHOLDER";
      };
      settingsFile = "/tmp/config.json";
      extraSettings = {
        tailscale-auth-key = "PLACEHOLDER";
        vless-uuids = {
          default = "PLACEHOLDER0";
          user = "PLACEHOLDER1";
        };
      };
      extraSettingsFile = "/tmp/extra-config.json";
    in
    pkgs.mkShellNoCC {
      packages = [ pythonEnv ];
      shellHook = ''
        mkdir -p .dev
        ln -sf ${lib.getBin pythonEnv}/bin/python .dev/python
        echo '${builtins.toJSON settings}' > ${settingsFile}
        echo '${builtins.toJSON extraSettings}' > ${extraSettingsFile}
      '';
      SETTINGS_FILE = settingsFile;
      EXTRA_SETTINGS_FILE = extraSettingsFile;
      DEBUG = 1;
    };
}
