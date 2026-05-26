{
  lib,
  config,
  ...
}:
{
  imports = [
    ./sing-box.nix
    ./mihomo.nix
  ];

  options.tunnel.client.enable = lib.mkEnableOption "tunnel client";

  config = {
    tunnel.client.sing-box.enable = lib.mkDefault config.tunnel.client.enable;

    age.secrets.reality-public-key.file = config.paths.secrets + "/reality-public-key.age";

    assertions = [
      {
        assertion = !config.tunnel.client.mihomo.enable || !config.tunnel.client.sing-box.enable;
        message = "Only one tunnel client can be enabled at the same time";
      }
    ];
  };
}
