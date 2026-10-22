{ config, pkgs, ... }:
{
  imports = [
    ./git
    ./neovim
    ./gh
  ];
  config.home-manager = {
    backupFileExtension = ".nix.bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${config.rag.username} = {
      home.stateVersion = config.system.stateVersion;
      home.enableNixpkgsReleaseCheck = false;
    };
  };
}
