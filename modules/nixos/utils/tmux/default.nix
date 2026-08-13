{ lib, ... }:
{
  config.programs.tmux = {
    enable = lib.mkDefault true;
    extraConfig = ''
      set -g mouse on
    '';
  };
}
