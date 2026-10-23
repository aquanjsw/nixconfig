{ lib, ... }: {
  programs.distrobox = {
    enable = lib.mkDefault true;
  };
}
