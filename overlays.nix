{ inputs, ... }:
[
  inputs.realcugan.overlays.default
  (final: prev: {
    rust-jemalloc-sys = prev.rust-jemalloc-sys.overrideAttrs (prevAttrs: {
      setupHook = prev.writeText "setup-hook.sh" ''
        export JEMALLOC_OVERRIDE="@out@/lib/libjemalloc_pic${prev.stdenv.hostPlatform.extensions.staticLibrary}"
      '';
    });
    sing-box = prev.sing-box.overrideAttrs (prevAttrs: rec {
      version = "1.14.0";
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
