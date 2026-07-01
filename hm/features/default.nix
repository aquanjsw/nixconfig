{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {

    user = lib.mkOption {
      default = "rag";
      readOnly = true;
    };

    isLimited = lib.mkOption {
      default = false;
    };

    isNixOS = lib.mkOption {
      default = true;
    };
  };

  config = {

    programs.fish.enable = true;

    programs.aria2 = {
      settings = {
        continue = true;
        max-connection-per-server = 8;
        split = 8;
        optimize-concurrent-downloads = true;
      };
    };

    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
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
      initLua = ''
        vim.lsp.enable('ruff')
        vim.lsp.enable('ty')
        vim.lsp.enable('nixd')
      '';
      extraConfig = ''
        syntax on
        set number
        set relativenumber
        set hlsearch
        set softtabstop=2
        set shiftwidth=2
        set autoindent
        set expandtab
        autocmd FileType python setlocal indentexpr=
        autocmd FileType python setlocal equalprg=ruff\ format\ -
        autocmd FileType nix setlocal equalprg=nixfmt
      '';
      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
      ];
    };

    programs.ruff.enable = true;
    programs.ty.enable = true;

    systemd.user.enable = true;

    services.podman.enable = true;
    services.podman.settings.containers = {
      engine.compose_warning_logs = false;
    };

    home.username = config.user;
    home.homeDirectory = "/home/${config.user}";
    home.packages =
      with pkgs;
      (
        [
          file
          tree
          yazi
          tmux
          btop
          dig
          nil
          nixd
          nixfmt
          jq
        ]
        ++ lib.optionals (!config.isNixOS) [ home-manager ]
      );
  };
}
