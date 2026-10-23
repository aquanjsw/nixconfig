{
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) readFile;
in
{
  programs.neovim = {
    enable = lib.mkDefault true;
    withRuby = false;
    withPython3 = false;
    defaultEditor = true;
    vimAlias = true;
    extraConfig = readFile ./init.vim;
    initLua = readFile ./init.lua;
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
    ];
  };
}
