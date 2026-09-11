{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./swap
    ./nvidia
    ./fonts
  ];

  config = {
    rag = {
      services.sing-box.role = lib.mkDefault "client";
      programs.apprise.enable = true;
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
      systemPackages = with pkgs; [
        file
        tree
        yazi
        btop
        dig
        jq
        dua
      ];
      sessionVariables = {
        EDITOR = "nvim";
      };
      memoryAllocator.provider = "jemalloc"; # to prevent memleak when using pytorch
    };

    networking.networkmanager.enable = true;
    networking.firewall.enable = false;
    networking.nftables.enable = true;

    time.timeZone = "Asia/Shanghai";
    i18n.defaultLocale = "en_US.UTF-8";

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    boot.loader.efi.canTouchEfiVariables = true;

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
  };
}
