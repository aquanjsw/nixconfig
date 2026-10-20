{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    ;
in
{
  config = mkIf config.services.kanata.enable {
    services.kanata = {
      keyboards = {
        default = {
          config = ''
            (defsrc
              caps
            )
            (defalias
              cap (tap-hold 200 200 f13 caps)
            )
            (deflayer base
              @cap
            )
          '';
        };
      };
    };
  };
}
