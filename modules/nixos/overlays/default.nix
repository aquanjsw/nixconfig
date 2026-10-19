{
  inputs,
  self,
  pkgs,
  ...
}:
{
  config = {
    nixpkgs.overlays = import "${self}/overlays.nix" { inherit inputs; };
    services.caddy.package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
      hash = "sha256-xRJ5evsAJ2akg47j3Bt6YDXJOgX88B/rKNP50KSVyNY=";
    };
  };
}
