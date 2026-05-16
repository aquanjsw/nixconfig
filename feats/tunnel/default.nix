{
  config,
  ...
}: {

  imports = [
    ./server
    ./client
    ./subscription.nix
  ];

  config.age.secrets = let
    path = config.paths.secrets;
  in {
    vless-uuid.file = path + "/vless-uuid.age";
  };
}