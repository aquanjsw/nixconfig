{
  lib,
  mkShellNoCC,
  python3,
  self,
  ...
}:
let
  pythonEnv = python3.withPackages (ps: [ ps.django ]);
  settings = import "${self}/modules/nixos/services/sing-box/client/settings.nix" { };
  settingsFile = "/tmp/config.json";
  extraSettings = {
    uuids = {
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
