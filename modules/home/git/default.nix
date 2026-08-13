{ config, ... }:
{
  config.home-manager.users.${config.rag.username} = {
    programs.git = {
      enable = true;
      settings = {
        user.name = "Shin Rag";
        user.email = "zhdlcc@gmail.com";
        init.defaultBranch = "main";
      };
    };
  };
}
