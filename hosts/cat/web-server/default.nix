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
          ./files
        ];
      };
      installPhase = ''
        mkdir -p $out
        cp -r index.html files $out
      '';
    };
  in
  {
    services.caddy = {
      httpsPort = 1443;
      environmentFile = config.age.secrets.caddy-env.path;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
        hash = "sha256-J0HWjCPoOoARAxDpG2bS9c0x5Wv4Q23qWZbTjd8nW84=";
      };
      globalConfig = ''
        acme_dns cloudflare {$CF_API_TOKEN}
      '';
      virtualHosts = {
        "${config.domain}".extraConfig = ''
          root * ${site}
          file_server
        '';
      };
    };
    age.secrets.caddy-env.file = config.paths.secrets + "/caddy-env.age";
  }
)
