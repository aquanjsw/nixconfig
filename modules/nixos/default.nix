{
  self,
  config,
  inputs,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    ./utils
    ./secrets
    ./services
    ./system
    ./user
    ./programs
  ];

  options.rag = {
    magicDNS = lib.mkOption {
      default = "${config.networking.hostName}.tail2fa86.ts.net";
    };
    email = lib.mkOption {
      default = "zhdlcc@gmail.com";
      readOnly = true;
    };
    rootDomain = lib.mkOption {
      default = "zaelggk.com";
      readOnly = true;
    };
    domain = lib.mkOption {
      default = "${config.networking.hostName}.${config.rag.rootDomain}";
    };
    username = lib.mkOption {
      default = "rag";
      readOnly = true;
    };
    ssh-keys = lib.mkOption {
      default = lib.strings.splitString "\n" (lib.strings.trim (builtins.readFile inputs.ssh-keys));
      readOnly = true;
    };
  };

  config = {
    rag = {
      services.sing-box.role = lib.mkDefault "client";
      services.sing-box.client.tailscaleCertDumper.enable = true;
    };

    programs.direnv.enable = true;
    programs.fish.enable = true;
    programs.nix-ld.enable = true;
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    services.sing-box.enable = true;
    services.openssh.enable = true;

    users.users.root = {
      hashedPassword = "$y$j9T$Y5Iio4JlEd0wIKlZHt1gG0$.FpHtOJBjHdk6yPSwEs7hVDrNRyOJ9r8CnV71rbLiS5";
      openssh.authorizedKeys.keys = config.rag.ssh-keys;
    };

    environment = {
      systemPackages = (
        with pkgs;
        [
          file
          tree
          yazi
          btop
          dig
          jq
          bintools # nm
          python3
        ]
      );
      sessionVariables = {
        EDITOR = "nvim";
        TS_DOMAIN = config.rag.magicDNS;
      };
    };

    networking.networkmanager.enable = true;
    networking.firewall.enable = false;
    networking.nftables.enable = true;

    time.timeZone = "Asia/Shanghai";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocales = [ "zh_CN.UTF-8/UTF-8" ];
    };

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    nixpkgs.config.allowUnfree = true;

    security.acme = {
      defaults = {
        email = config.rag.email;
        dnsProvider = "cloudflare";
      };
      acceptTerms = true;
    };

    nix.gc = {
      automatic = true;
      options = lib.mkDefault "--delete-older-than 30d";
      dates = "weekly";
    };

    nix.optimise = {
      automatic = true;
      dates = "weekly";
    };

    boot.loader = {
      grub = {
        enable = true;
        device = lib.mkDefault "nodev";
        efiSupport = lib.mkDefault true;
      };
      efi.canTouchEfiVariables = lib.mkDefault true;
    };

    nix.settings.substituters = [ "https://mirrors.cernet.edu.cn/nix-channels/store?priority=10" ];
    nixpkgs.overlays = import "${self}/overlays.nix" { inherit inputs; };

    systemd.settings.Manager = {
      DefaultTimeoutStopSec = "10s";
    };
  };
}
