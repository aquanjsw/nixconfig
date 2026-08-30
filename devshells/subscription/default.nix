{
  lib,
  mkShellNoCC,
  python3,
  self,
  ...
}:
let
  pythonEnv = python3.withPackages (ps: [ ps.django ]);
  settings = import "${self}/modules/nixos/services/sing-box/client/settings.nix" {
    vless-server = "PLACEHOLDER";
    vless-uuid = "PLACEHOLDER";
    reality-public-key = "PLACEHOLDER";
    tailscale-auth-key = "PLACEHOLDER";
    api-port = 2353;
  };
  settingsFile = "/tmp/config.json";
  extraSettings = {
    vless-uuids = {
      default = "PLACEHOLDER0";
      user = "PLACEHOLDER1";
    };
  };
  extraSettingsFile = "/tmp/extra-config.json";
in
mkShellNoCC {
  packages = [ pythonEnv ];
  shellHook = ''
    mkdir -p .dev
    ln -sf ${lib.getBin pythonEnv}/bin/python .dev/python
    echo '${builtins.toJSON settings}' > ${settingsFile}
    echo '${builtins.toJSON extraSettings}' > ${extraSettingsFile}
  '';
  SETTINGS_FILE = settingsFile;
  EXTRA_SETTINGS_FILE = extraSettingsFile;
  SERVER_SETTINGS_FILE = "";
  STOLEN_SERVER = "";
  DEBUG = 1;
}
