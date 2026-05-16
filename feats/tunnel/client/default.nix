{
  config,
  ...
}: {

  imports = [
    ./sing-box.nix
    ./mihomo.nix
  ];

  config.age.secrets = let
    path = config.paths.secrets;
  in {
    reality-public-key.file = path + "/reality-public-key.age";
  };
}