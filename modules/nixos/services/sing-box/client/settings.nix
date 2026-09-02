{
  vless-server,
  vless-uuid,
  reality-public-key,
  tailscale-auth-key,
  api-port,
}:
{
  "$schema" = "https://sing-box.sagernet.org/schema.json";
  log = {
    disabled = false;
    level = "debug";
    timestamp = false;
  };
  dns = {
    strategy = "prefer_ipv4";
    servers = [
      {
        type = "udp";
        tag = "remote";
        server = "1.1.1.1";
        detour = "proxy";
      }
      {
        type = "local";
        tag = "local";
      }
      {
        type = "tailscale";
        tag = "ts-dns";
        endpoint = "ts-ep";
      }
    ];
    rules = [
      {
        query_type = "TXT";
        server = "remote";
        disable_cache = true;
      }
      {
        action = "predefined";
        rule_set = [
          "geosite-category-ads-all"
        ];
      }
      {
        server = "local";
        rule_set = [
          "geosite-cn"
        ];
        domain_suffix = [
          ".lan"
        ];
      }
      {
        preferred_by = "ts-dns";
        server = "ts-dns";
      }
    ];
  };
  http_clients = [
    {
      detour = "proxy";
      tag = "default";
    }
  ];
  route = {
    default_domain_resolver = "local";
    auto_detect_interface = true;
    default_http_client = "";
    rule_set = [
      {
        tag = "geosite-private";
        type = "remote";
        format = "binary";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-private.srs";
      }
      {
        tag = "geosite-category-ads-all";
        type = "remote";
        format = "binary";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ads-all.srs";
      }
      {
        tag = "geosite-cn";
        type = "remote";
        format = "binary";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-cn.srs";
      }
      {
        tag = "geoip-cn";
        type = "remote";
        format = "binary";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs";
      }
    ];
    rules = [
      {
        action = "sniff";
      }
      {
        protocol = "dns";
        action = "hijack-dns";
      }
      {
        network = "icmp";
        outbound = "direct";
      }
      {
        protocol = "bittorrent";
        outbound = "direct";
      }
      {
        process_name = [
          "leigod.exe"
          "leishenSdk.exe"
        ];
        outbound = "direct";
      }
      {
        action = "reject";
        rule_set = [
          "geosite-category-ads-all"
        ];
      }
      {
        domain_suffix = [
          ".zi0.cc"
          ".googleapis.com"
          ".googleapis.cn"
          ".google.cn"
          ".gvt2.com"
          ".gstatic.com"
        ];
        outbound = "proxy";
      }
      {
        rule_set = [
          "geosite-private"
          "geosite-cn"
          "geoip-cn"
        ];
        ip_is_private = true;
        outbound = "direct";
      }
      {
        ip_cidr = "100.64.0.0/10";
        outbound = "ts-ep";
      }
      {
        preferred_by = [ "ts-ep" ];
        outbound = "ts-ep";
      }
    ];
    final = "proxy";
  };
  inbounds = [
    {
      type = "mixed";
      listen = "::0";
      listen_port = 7890;
    }
    {
      type = "tun";
      address = [
        "172.19.0.1/30"
        "fdfe:dcba:9876::1/126"
      ];
      auto_route = true;
      auto_redirect = true;
      strict_route = true;
    }
  ];
  outbounds = [
    {
      type = "direct";
      tag = "direct";
    }
    {
      type = "vless";
      tag = "proxy";
      server = vless-server;
      server_port = 443;
      uuid = vless-uuid;
      flow = "xtls-rprx-vision";
      tls = {
        enabled = true;
        server_name = vless-server;
        reality = {
          enabled = true;
          public_key = reality-public-key;
          short_id = "";
        };
        utls = {
          enabled = true;
        };
      };
      transport = {
        type = "httpupgrade";
      };
    }
  ];
  endpoints = [
    {
      type = "tailscale";
      tag = "ts-ep";
      auth_key = tailscale-auth-key;
      ephemeral = false;
    }
  ];
  services = [
    {
      type = "api";
      listen = "0.0.0.0";
      listen_port = api-port;
      access_control_allow_private_network = true;
      dashboard = {
        enabled = true;
      };
    }
  ];
}
