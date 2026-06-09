{
  config,
  lib,
  ...
}:
lib.mkIf config.services.searx.enable {
  services.searx.environmentFile = config.age.secrets.searx.path;
  services.searx.settings = {
    server = {
      port = 10080;
      bind_address = "0.0.0.0";
      secret_key = "$SECRET_KEY";
      safe_search = 0;
      image_proxy = true;
      limiter = true;
    };
    search.formats = [
      "json"
      "html"
    ];
    valkey.url = "valkey://localhost:6379/0";
  };
  services.searx.limiterSettings = {
    botdetection.ip_limit = {
      link_token = false;
      filter_link_local = false;
    };
  };
  age.secrets.searx.file = config.paths.secrets + "/searx.age";
}
