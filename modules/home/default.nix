{ config, ... }:
{
  imports = [
    ./git
    ./neovim
    ./gh
  ];
  config.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${config.rag.username}.home.stateVersion = config.system.stateVersion;
  };
}
