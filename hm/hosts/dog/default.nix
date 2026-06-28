{
  pkgs,
  ...
}:
{
  imports = [
    ./../../features
  ];
  config = {
    home.packages = with pkgs; [
      podman-compose
    ];
    home.stateVersion = "25.11";
  };
}
