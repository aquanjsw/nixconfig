{ inputs, ... }:
[
  inputs.realcugan.overlays.default
  inputs.ragixpkgs.overlays.default
  (
    final: prev:
    let
      inherit (prev) lib;
    in
    {
      waybar = (
        prev.waybar.overrideAttrs (
          prevAttrs:
          let
            libcava = rec {
              version = "1.0.0";
              src = prev.fetchFromGitHub {
                owner = "LukashonakV";
                repo = "cava";
                # NOTE: Needs to match the cava.wrap
                tag = "${version}";
                hash = "sha256-0r5aAmTs+FcmS501tNYKxG9H+Pq6i32BDRBEjWW6M74=";
              };
            };
          in
          {
            version = "0.15.0-dynamic-bar";
            src = prev.fetchFromGitHub {
              owner = "aquanjsw";
              repo = "Waybar";
              rev = "6739245ad8f4cfaede89445afc6422f0cd93ec76";
              hash = "sha256-dOcbwtufig2m7YcmM1XlVXXWsCfcU/WdFp3p8QLDWoM=";
            };
            buildInputs =
              (builtins.filter (p: p.pname != "wireplumber" && p.pname != "gps") prevAttrs.buildInputs)
              ++ [
                prev.wireplumber
                prev.gpsd
                prev.modemmanager
              ];
            postUnpack = ''
              pushd "$sourceRoot"
              cp -R --no-preserve=mode,ownership ${libcava.src} subprojects/cava-${libcava.version}
              patchShebangs .
              popd
            '';
            nativeInstallCheckInputs = [ ];
            doInstallCheck = false;
          }
        )
      );
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
    }
  )
]
