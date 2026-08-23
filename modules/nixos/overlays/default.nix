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
          version = "1.14.0-beta.17";
          src = pkgs.fetchFromGitHub {
            owner = "SagerNet";
            repo = "sing-box";
            tag = "v${version}";
            hash = "sha256-7kn2UcCbea3v203U4knzbCKQECPCobIQXMy705RYucQ=";
          };
          vendorHash = "sha256-9Cv3WJG2C3yMk1d8UCLMIhgM5Q9dYAYp7A0F1LdZm/s";
        });
      })
    ];
  };
}
