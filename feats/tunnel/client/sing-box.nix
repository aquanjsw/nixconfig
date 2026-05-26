{
  lib,
  config,
  ...
}:
{

  options.tunnel.client.sing-box.settings = lib.mkOption {
    readOnly = true;
    default = {

      log = {
        disabled = false;
        level = "error";
        timestamp = true;
      };

      dns = {
        strategy = "prefer_ipv4"; # CERNET's IPv6 connectivity is terrible

        independent_cache = true; # remove in 1.14.0+

        disable_expire = true;
        # optimistic.enabled = true; # replace above in 1.14.0+

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
          {
            type = "fakeip";
            tag = "fakeip";
            inet4_range = "198.18.0.0/15";
          }
        ];

        rules = [
          {
            action = "predefined";
            rcode = "NOERROR"; # SUCCESS
            rule_set = [
              "geosite-category-ads-all"
            ];
          }
          {
            domain_suffix = [ ".ts.net" ];
            server = "ts-dns";
          }
          {
            query_type = [ "A" ];
            server = "fakeip";
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
            domain = [
              config.domain
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
            process_name = [
              "frpc"
              "frpc.exe"
            ];
            outbound = "proxy";
          }
          {
            action = "route";
            outbound = "proxy";
            domain = [ config.domain ];
            port = [
              22000
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
              "hf-mirror.com"
              config.domain
            ];
            ip_is_private = true;
            outbound = "direct";
          }
          {
            action = "route";
            preferred_by = [ "ts-ep" ];
            outbound = "ts-ep";
          }
          {
            action = "route";
            outbound = "proxy";
            network = [
              "tcp"
              "udp"
            ];
          }
        ];
      };

      experimental = {
        cache_file = {
          enabled = true;
          store_fakeip = true;
        };
        clash_api = {
          external_controller = ":9090";
          secret._secret = config.age.secrets.clash-api-secret.path;
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
          ];
          auto_route = true;
          auto_redirect = true;
          strict_route = true;
          route_exclude_address = [
            "10.0.0.0/8"
            "192.168.0.0/16"
          ];
          exclude_package = [
            "com.jingdong.app.mall"
            "com.coolapk.market"
            "com.autonavi.minimap"
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
        }
      ];

      endpoints = [
        {
          type = "tailscale";
          tag = "ts-ep";
          auth_key._secret = config.age.secrets.tailscale-auth-key.path;
        }
      ];
    };
  };

  options.tunnel.client.sing-box.enable = lib.mkEnableOption "sing-box client";

  config = {

    age.secrets = {
      clash-api-secret.file = config.paths.secrets + "/clash-api-secret.age";
      tailscale-auth-key.file = config.paths.secrets + "/tailscale-auth-key.age";
    };

    services.sing-box = lib.mkIf config.tunnel.client.sing-box.enable {
      enable = true;
      settings = config.tunnel.client.sing-box.settings;
    };

    tunnel.subscription.sing-box.settings = config.tunnel.client.sing-box.settings;

    web-app.subscription.sing-box = lib.mkIf config.web-app.enable {
      configPath = config.tunnel.subscription.sing-box.path;
      urlPath = "sing-box.json";
    };
  };
}
