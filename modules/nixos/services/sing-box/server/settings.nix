{
  vless-uuids,
  server-name,
  handshake-server,
  handshake-port,
  reality-private-key,
  res-password,
  api-port,
  api-secret,
}:
{
  "$schema" = "https://sing-box.sagernet.org/schema.json";
  log = {
    disabled = false;
    level = "debug";
    timestamp = false;
  };
  outbounds = [
    {
      type = "direct";
      tag = "direct";
    }
    {
      tag = "warp";
      type = "socks";
      server = "127.0.0.1";
      server_port = 40000;
    }
    {
      tag = "res-us";
      type = "socks";
      server = "gw.dataimpulse.com";
      server_port = 824;
      username = "967395487d806a6940d5__cr.us";
      password = res-password;
    }
    {
      tag = "res-hk";
      type = "socks";
      server = "gw.dataimpulse.com";
      server_port = 824;
      username = "967395487d806a6940d5__cr.hk";
      password = res-password;
    }
  ];
  inbounds = [
    {
      type = "vless";
      listen = "::0";
      listen_port = 443;
      users = map (uuid: {
        inherit uuid;
        flow = "xtls-rprx-vision";
      }) vless-uuids;
      tls = {
        enabled = true;
        server_name = server-name;
        reality = {
          enabled = true;
          private_key = reality-private-key;
          short_id = [ "" ];
          handshake = {
            server = handshake-server;
            server_port = handshake-port;
          };
        };
      };
      transport = {
        type = "httpupgrade";
      };
    }
  ];
  route = {
    final = "direct";
    rules = [
      {
        action = "sniff";
      }
      # {
      #   action = "route";
      #   rule_set = [
      #     "geosite-google"
      #   ];
      #   outbound = "res-hk";
      # }
    ];
    rule_set = [
      {
        tag = "geosite-google";
        type = "remote";
        format = "binary";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-google.srs";
      }
    ];
  };
  services = [
    {
      type = "api";
      secret = api-secret;
      listen = "127.0.0.1";
      listen_port = api-port;
      dashboard = {
        enabled = true;
      };
    }
  ];
}
