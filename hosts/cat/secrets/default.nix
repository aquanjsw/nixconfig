{
  config,
  self,
  ...
}:
let
  hostName = config.networking.hostName;
in
{
  config.sops = {
    secrets = {
      "sing-box/api-secret" = {
        sopsFile = "${self}/secrets/${hostName}.yaml";
      };
      "sing-box/uuids/430" = {
        sopsFile = "${self}/secrets/${hostName}.yaml";
      };
      "caddy/hashed-passwd" = {
        sopsFile = "${self}/secrets/${hostName}.yaml";
      };
      "dataimpulse-passwd" = {
        sopsFile = "${self}/secrets/${hostName}.yaml";
      };
      "django-key" = {
        sopsFile = "${self}/secrets/${hostName}.yaml";
      };
    };
  };
}
