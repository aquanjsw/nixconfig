{
  config,
  lib,
  ...
}:
lib.mkIf config.services.samba.enable {
  services.samba.settings = {
    global = {
      "wide links" = "yes";
      "unix extensions" = "no";
    };
    public = {
      path = "/samba";
      browseable = "yes";
      "read only" = "no";
    };
  };
}
