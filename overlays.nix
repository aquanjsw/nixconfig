{ inputs, ... }:
[
  inputs.realcugan.overlays.default
  inputs.ragixpkgs.overlays.default
  (final: prev: {
    caddy = (
      prev.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
        hash = "sha256-xRJ5evsAJ2akg47j3Bt6YDXJOgX88B/rKNP50KSVyNY=";
      }
    );
    zed = (
      prev.symlinkJoin {
        name = "zed";
        paths = [ prev.zed-editor ];
        postBuild = ''
          ln -s $out/bin/zeditor $out/bin/zed
        '';
      }
    );
    sing-box = prev.sing-box.overrideAttrs (prevAttrs: rec {
      version = "1.15.0-alpha.12";
      src = prev.fetchFromGitHub {
        owner = "SagerNet";
        repo = "sing-box";
        tag = "v${version}";
        hash = "sha256-1v9bgM2H439ZoSkomv5dmT5SNrkuyOJ1iFFPlYPsW/k=";
      };
      vendorHash = "sha256-Bl73SkmnOyh5kULctDaxcOzXsYXRY2DOt80ME2+lBJo=";
    });
  })
]
