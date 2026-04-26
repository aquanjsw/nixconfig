{
  pkgs,
  utils,
  config,
  ...
}: {

  imports = [
    ./server
    ./client.nix
  ];

  systemd.services.generateSubscription = {
    description = "Generate Tunnel Client Subscription";
    after = [ "caddy.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = let 
        script = pkgs.writeShellScript "gen-tunnel-client-config" ''
          ${utils.genJqSecretsReplacementSnippet
            config.tunnel.client.config
            "${config.services.caddy.dataDir}/config.json"}
          chown --reference="${config.services.caddy.dataDir}" \
            "${config.services.caddy.dataDir}/config.json"
        '';
      in "+${script}";
    };
  };
}