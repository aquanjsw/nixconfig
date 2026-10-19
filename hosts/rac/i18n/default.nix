{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      (fcitx5-rime.override {
        rimeDataPkgs = [
          rime-ice
        ];
      })
      fcitx5-mozc
    ];
  };
}
