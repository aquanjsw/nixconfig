{
  config,
  lib,
  pkgs,
  ...
}:
{
  config.home-manager.users.${config.rag.username} = {
    programs.neovim = {
      enable = true;
      withRuby = false;
      withPython3 = false;
      defaultEditor = true;
      vimAlias = true;
      extraConfig = lib.fileContents ./init.vim;
      initLua = lib.fileContents ./init.lua;
      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
      ];
    };
  };
}
