{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.services.caddy.enable (
  let
    site = pkgs.stdenv.mkDerivation {
      name = "site";
      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./index.html
        ];
      };
      installPhase = ''
        mkdir -p $out
        cp -r index.html $out
      '';
    };
  in
  {
    sops.templates."caddy.env".content = ''
      CF_API_TOKEN=${config.sops.placeholder.cf-api-token}
      HASHED_PASSWD=${config.sops.placeholder."caddy/hashed-passwd"}
    '';
    services.caddy = {
      httpsPort = 1443;
      environmentFile = config.sops.templates."caddy.env".path;
      globalConfig = ''
        acme_dns cloudflare {$CF_API_TOKEN}
      '';
      virtualHosts = {
        "${config.rag.rootDomain}".extraConfig = ''
          root * ${site}
          file_server
        '';
      };
    };
  }
)
