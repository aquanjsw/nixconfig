{ lib, ... }:
{
  programs.gh = {
    enable = lib.mkDefault true;
    gitCredentialHelper.enable = true;
  };
}
