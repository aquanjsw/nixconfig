{
  lib,
  config,
  self,
  ...
}:
let
  inherit (lib)
    mkIf
    ;
  inherit (builtins)
    hasAttr
    ;
in
{
  config = {
    sops = {
      defaultSopsFile = "${self}/secrets/default.yaml";
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      secrets = {
        "sing-box/uuids/default" = { };
        "sing-box/reality/private-key" = { };
        "sing-box/reality/public-key" = { };
        cf-api-token = { };
        ts-auth-key = { };
      };
      templates = {
        "cf.env".content = ''
          CF_API_TOKEN=${config.sops.placeholder.cf-api-token}
        '';
      };
    };
  };
}
