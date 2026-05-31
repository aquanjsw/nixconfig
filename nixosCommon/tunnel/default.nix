{
  config,
  ...
}: {

  imports = [
    ./server
    ./client
    ./subscription.nix
  ];

  config.age.secrets.vless-uuid.file = config.paths.secrets + "/vless-uuid.age";
}
