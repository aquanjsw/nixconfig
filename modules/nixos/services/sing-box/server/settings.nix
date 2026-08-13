{
  vless-uuids,
  server-name,
  server-port,
  reality-private-key,
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
            server = server-name;
            server_port = server-port;
          };
        };
      };
      transport = {
        type = "httpupgrade";
      };
    }
  ];
}
