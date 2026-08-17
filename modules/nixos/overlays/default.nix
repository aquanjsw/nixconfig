{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  config = {
    nixpkgs.overlays = [
      inputs.realcugan.overlays.default
      (final: prev: {
        rust-jemalloc-sys = prev.rust-jemalloc-sys.overrideAttrs (prevAttrs: {
          setupHook = pkgs.writeText "setup-hook.sh" ''
            export JEMALLOC_OVERRIDE="@out@/lib/libjemalloc_pic${config.nixpkgs.hostPlatform.extensions.staticLibrary}"
          '';
        });
        sing-box = prev.sing-box.overrideAttrs (prevAttrs: rec {
          version = "1.14.0-beta.15";
          src = pkgs.fetchFromGitHub {
            owner = "SagerNet";
            repo = "sing-box";
            tag = "v${version}";
            hash = "sha256-fUaq2tyC2kTDveKhRMB+TQMZLL515MqkyK8mS85U7kI=";
          };
          vendorHash = "sha256-4MtT1e8OQBo7kp0pZ7AnQwru3CRGdcSdLSrb3jGUxK0=";
        });
      })
    ];
  };
}
