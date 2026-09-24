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
      hash = "sha256-dQvk6ezY6TQ1J7PjhCXnThF/SqVgPwBO8/RXzHCY+js";
    };
  };
}
