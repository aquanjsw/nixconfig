{ config, ... }:
{
  config.home-manager.users.${config.rag.username} = {
    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
  };
}
