{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      source-han-sans
      nerd-fonts.symbols-only
    ];
    fontconfig.defaultFonts = {
      sansSerif = [ "Source Han Sans SC" ];
    };
  };

  home-manager.users.rag.i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    # Using `fcitx5-remote -r` to reload the following settings
    fcitx5 = {
      ignoreUserConfig = true;
      waylandFrontend = true;
      addons = with pkgs; [
        (fcitx5-rime.override {
          rimeDataPkgs = [ rime-ice ];
        })
        fcitx5-mozc
      ];
      settings = {
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "rime";
          "Groups/0/Items/2".Name = "mozc";
        };
        globalOptions = {
          "Hotkey/AltTriggerKeys"."0" = "Tools"; # Caps_Lock as activation toggle
          "Hotkey/TriggerKeys" = { }; # Disable Ctrl+Space
        };
        addons = {
          rime.globalSection = {
            InputState = "Program";
            SwitchInputMethodBehavior = "\"Commit raw input\"";
          };
        };
      };
    };
  };
}
