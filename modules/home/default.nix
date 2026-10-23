{ config, ... }:
{
  config.home-manager = {
    backupFileExtension = ".nix.bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.rag = {
      imports = [
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
      config.home = {
        stateVersion = config.system.stateVersion;
        homeDirectory = "/home/rag";
        username = "rag";
      };
    };
  };
}
