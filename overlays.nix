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
      version = "1.14.0-rc.4";
      src = prev.fetchFromGitHub {
        owner = "SagerNet";
        repo = "sing-box";
        tag = "v${version}";
        hash = "sha256-9ybFSCPCGCvanWgRjLFtb/tejz/gSlo/R9E754JDSDM=";
      };
      vendorHash = "sha256-RWCCScJVaKTmNrBiGips6QWz6EFTBXXMNsi+UqNvnjU=";
    });
  })
]
