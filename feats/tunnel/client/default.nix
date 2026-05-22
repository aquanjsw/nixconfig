{
  config,
  ...
}: {

  imports = [
    ./sing-box.nix
    ./mihomo.nix
  ];

  config.age.secrets.reality-public-key.file = config.paths.secrets + "/reality-public-key.age";
}
