{
  config,
  ...
}:
{
  log = {
    disabled = false;
    level = "debug";
    timestamp = false;
  };
  dns = {
    independent_cache = true;
    strategy = "prefer_ipv4";
    servers = [
      {
        type = "udp";
        tag = "remote";
        server = "1.1.1.1";
        detour = "proxy";
      }
      {
        # Only linux needs dhcp, other platforms just use local
        type = "dhcp";
        tag = "local";
      }
      # This server, plus the corresponding rule following, only takes effect
      # on linux in reality (in the situation where tailscale's default tun mode
      # and sing-box's tun are both enabled):
      # - Windows: tailscaled hijack tailscale dns requests in another earlier
      #   stage, sing-box's tun will never see them, and thus never hijack them
      # - Android: typically tailscale and sing-box can not run simultaneously
      # So, we can safely express these configs without worrying about conflicts
      {
        type = "udp";
        tag = "tailscale-dns";
        server = "100.100.100.100";
        bind_interface = "tailscale0";
      }
    ];
    rules = [
      {
        action = "predefined";
        rcode = "NOERROR";
        rule_set = [
          "geosite-category-ads-all"
        ];
      }
      {
        action = "route";
        server = "local";
        rule_set = [
          "geosite-cn"
          "geosite-ieee"
        ];
        domain_suffix = [
          ".lan"
        ];
      }
      {
        action = "route";
        server = "tailscale-dns";
        domain_suffix = [
          ".ts.net"
        ];
      }
    ];
  };
  route = {
    final = "direct";
    default_domain_resolver = "local";
    auto_detect_interface = true;
    rule_set = [
      {
        tag = "geosite-private";
        type = "remote";
        format = "binary";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-private.srs";
        download_detour = "proxy";
      }
      {
        tag = "geosite-category-ads-all";
        type = "remote";
        format = "binary";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ads-all.srs";
        download_detour = "proxy";
      }
      {
        tag = "geosite-cn";
        type = "remote";
        format = "binary";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-cn.srs";
        download_detour = "proxy";
      }
      {
        tag = "geosite-ieee";
        type = "remote";
        format = "binary";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-ieee.srs";
        download_detour = "proxy";
      }
      {
        tag = "geoip-cn";
        type = "remote";
        format = "binary";
        url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs";
        download_detour = "proxy";
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
        action = "route";
        process_name = [
          "leigod.exe"
          "leishenSdk.exe"
          "qbittorrent-nox"
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
        action = "route";
        domain_suffix = [
          "zi0.cc"
          "googleapis.com"
          "googleapis.cn"
          "google.cn"
          "gvt2.com"
          "gstatic.com"
        ];
        outbound = "proxy";
      }
      {
        action = "route";
        rule_set = [
          "geosite-private"
          "geosite-cn"
          "geosite-ieee"
          "geoip-cn"
        ];
        domain_suffix = [
          config.domain
        ];
        ip_is_private = true;
        outbound = "direct";
      }
      {
        action = "route";
        outbound = "proxy";
        network = [
          # vless doesn't support other protocols
          "tcp"
          "udp"
        ];
      }
    ];
  };
  experimental = {
    cache_file = {
      enabled = true;
    };
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
      exclude_package = [
        "com.jingdong.app.mall"
        "com.coolapk.market"
        "com.autonavi.minimap"
        "com.netease.cloudmusic"
      ];
      route_exclude_address = [
        # Bypass NAT-PMP/UPnP-IGD/PCP traffic
        "192.168.0.0/16"
        "10.0.0.0/8"
        "224.0.0.0/4"
        # Bypass tailnet traffic
        "100.64.0.0/10"
        "fd7a:115c:a1e0::/48"
      ];
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
      server = config.domain;
      server_port = 443;
      uuid._secret = config.age.secrets.vless-uuid.path;
      flow = "xtls-rprx-vision";
      tls = {
        enabled = true;
        server_name = config.domain;
        reality = {
          enabled = true;
          public_key._secret = config.age.secrets.reality-public-key.path;
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
}
