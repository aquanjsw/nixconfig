{ config, pkgs, ... }:
{
  imports = [
    ./git
    ./neovim
    ./gh
  ];
  config.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${config.rag.username} = {
      home.packages = with pkgs; [
        ty
        ruff
        nixd
        nixfmt
      ];
      home.stateVersion = "26.11";
    };
  };
}
