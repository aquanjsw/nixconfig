{ config, ... }:
{
  imports = [
    ./sing-box.nix
    ./xray.nix
    ./subscription.nix
  ];

  config.age.secrets.vless-uuid.file = config.paths.secrets + "/vless-uuid.age";
}
