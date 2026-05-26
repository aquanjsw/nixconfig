{
  config,
  lib,
  ...
}:
{
  options.syncthing.guiPort = lib.mkOption {
    default = 8384;
    readOnly = true;
  };

  config = lib.mkIf config.services.syncthing.enable {
    services.syncthing = {
      guiAddress = "0.0.0.0:${toString config.syncthing.guiPort}";
      guiPasswordFile = config.age.secrets.syncthingGuiPassword.path;
    };

    age.secrets.syncthingGuiPassword.file = config.paths.secrets + "/syncthingGuiPassword.age";
  };
}
