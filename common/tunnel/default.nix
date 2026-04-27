{
  lib,
  pkgs,
  utils,
  config,
  ...
}: {

  imports = [
    ./server
    ./client.nix
  ];

  # TODO: dirname 'subscription' could be optionized to sync with the following
  # systemd service unit file.

  # TODO: fname 'config.json' could also be optionized to sync with the systemd
  # service unit file and the web server config `urls.py`.
  options.tunnel.subscriptionPath = lib.mkOption {
    type = lib.types.str;
    default = "/run/subscription/config.json";
  };

  config.systemd.services.generateSubscription = lib.mkIf config.tunnel.server.enable {
    description = "Generate Tunnel Client Subscription";
    after = [ "caddy.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RuntimeDirectory = "subscription";
      RuntimeDirectoryPreserve = "yes";
      ExecStart = let 
        script = pkgs.writeShellScript "gen-tunnel-client-config" ''
          ${utils.genJqSecretsReplacementSnippet
            config.tunnel.client.config
            "/run/subscription/config.json"}
        '';
      in "+${script}";
    };
  };
}