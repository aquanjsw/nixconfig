{ lib, ... }:
{
  programs.git = {
    enable = lib.mkDefault true;
    settings = {
      user.name = "Shin Rag";
      user.email = "zhdlcc@gmail.com";
      init.defaultBranch = "main";
    };
  };
}
