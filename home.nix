{
  args,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  finalArgs = config // args;
in
{

  programs.aria2 = {
    enable = true;
    settings = {
      continue = true;
      max-connection-per-server = 8;
      split = 8;
      optimize-concurrent-downloads = true;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "aquanjsw";
      user.email = "zhdlcc@gmail.com";
      init.defaultBranch = "main";
    };
  };

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
    plugins = with pkgs.vimPlugins; [
    ];
  };

  home.username = finalArgs.user;
  home.homeDirectory = "/home/${finalArgs.user}";
  home.packages =
    with pkgs;
    (
      [
        gh
        tree
        yazi
        tmux
        btop
        dig
      ]
      ++ lib.optionals (!finalArgs.isLimited) [
        inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
        nil
        nixd
        nixfmt
      ]
      ++ lib.optionals (!finalArgs.isNixOS) [ home-manager ]
    );

  home.stateVersion = "25.11";
}
