{ ... }:
{
  config.home-manager = {
    backupFileExtension = ".nix.bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.rag = (
      { lib, osConfig, ... }: {
        imports = [
          ./swayidle
          ./wl-gammarelay-rs
          ./swaylock
          ./mako
          ./distrobox
          ./cliplist
          ./waybar
          ./git
          ./neovim
          ./gh
          ./awww
          ./fcitx5
          ./awww
        ];
        config = lib.mkMerge [
          {
            home = {
              stateVersion = osConfig.system.stateVersion;
              homeDirectory = "/home/rag";
              username = "rag";
            };
          }
          (lib.mkIf osConfig.programs.niri.enable {
            services.wl-gammarelay-rs.enable = lib.mkDefault true;
          })
        ];
      }
    );
  };
}
