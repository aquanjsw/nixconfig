{
  config,
  inputs,
  pkgs,
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
      })
    ];
  };
}
