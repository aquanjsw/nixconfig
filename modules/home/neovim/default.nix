{ config, ... }:
{
  config.home-manager.users.${config.rag.username} = {
    programs.neovim = {
      enable = true;
      withRuby = false;
      withPython3 = false;
      defaultEditor = true;
      vimAlias = true;
      extraConfig = ''
        syntax on
        set number
        set relativenumber
        set hlsearch
        set softtabstop=2
        set shiftwidth=2
        set autoindent
        set expandtab
      '';
    };
  };
}
