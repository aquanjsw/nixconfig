{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {

    user = lib.mkOption {
      default = "rag";
      readOnly = true;
    };

    isLimited = lib.mkOption {
      default = false;
      description = "Whether the system is limited in resources.";
    };

    isOutside = lib.mkOption {
      default = false;
      description = "Whether the system is outside.";
    };

    isBareMetal = lib.mkOption {
      default = false;
      description = "Whether the system is running on bare metal.";
    };

    domain = lib.mkOption {
      default = "zaelggk.com";
      readOnly = true;
    };

    swapfileSize = lib.mkOption {
      default = 4 * 1024;
      description = "The size of the swapfile in MiB.";
    };

  };

  config =
    let
      ssh-keys = lib.strings.splitString "\n" (lib.strings.trim (builtins.readFile inputs.ssh-keys));
    in
    {
      users.users.${config.user} = {
        hashedPassword = "$y$j9T$Jj8kNaBhl9pdqRsFH.5Rw0$au/4czArJfGinqyBNueuzkt1QTO5mljFzAH9L5pVeR9";
        isNormalUser = true;
        extraGroups = [
          "wheel"
        ]
        ++ lib.optional (config.virtualisation.libvirtd.enable) "libvirtd";
        shell = pkgs.fish;
        openssh.authorizedKeys.keys = ssh-keys;
        linger = true;
        packages =
          with pkgs;
          [ ]
          ++ lib.optionals (!config.isLimited) [
            inputs.agenix.packages.${stdenv.hostPlatform.system}.default
          ];
      };
      users.users.root.hashedPassword = "$y$j9T$Y5Iio4JlEd0wIKlZHt1gG0$.FpHtOJBjHdk6yPSwEs7hVDrNRyOJ9r8CnV71rbLiS5";
      users.users.root.openssh.authorizedKeys.keys = ssh-keys;

      environment.systemPackages =
        with pkgs;
        (
          [
          ]
          ++ lib.optionals (config.isBareMetal) [
            usbutils
            pciutils
          ]
        );

      programs.fish.enable = true;
      programs.nix-ld.enable = !config.isLimited; # For VSCode server

      services.openssh.enable = true;
      services.openssh.settings.PasswordAuthentication = false;

      virtualisation.oci-containers.backend = "podman";
      virtualisation.podman = {
        defaultNetwork.settings = {
          dns_enabled = true;
        };
        autoPrune.enable = true;
      };
      hardware.nvidia-container-toolkit.enable = builtins.elem "nvidia" config.services.xserver.videoDrivers;

      networking.networkmanager.enable = true;
      networking.iproute2.enable = true;
      networking.firewall.enable = false;
      networking.nftables.enable = true;

      zramSwap.enable = true;
      zramSwap.priority = 100;
      systemd.oomd.enable = true;
      swapDevices = [
        {
          device = "/var/lib/swapfile";
          size = config.swapfileSize;
          priority = 5;
        }
      ];

      time.timeZone = "Asia/Shanghai";

      i18n.defaultLocale = "en_US.UTF-8";

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix.settings.substituters = lib.optionals (!config.isOutside) [
        "https://mirrors.cernet.edu.cn/nix-channels/store"
      ];

      nixpkgs.overlays = [
        inputs.realcugan.overlays.default
        (
          final: prev:
          let
            unstable = import inputs.nixpkgs-unstable {
              system = prev.stdenv.hostPlatform.system;
              config.allowUnfree = true;
            };
          in
          {
            open-webui = unstable.open-webui;
            opencode = unstable.opencode;
            rtk = unstable.rtk;
            sing-box = unstable.sing-box;

            python3Packages = prev.python3Packages.override {
              overrides = self: super: {
                huggingface-hub = unstable.python3Packages.huggingface-hub;
              };
            };
          }
        )
      ];
      nixpkgs.config.allowUnfree = true;

      age.secrets.huggingface-env = {
        file = config.paths.secrets + "/huggingface-env.age";
        owner = config.user;
      };

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    };

  imports = [
    ./tunnel
    ./derper.nix
    ./beszel
    ./syncthing.nix
    ./syncthing-discovery.nix
    ./dnf.nix
    ./web-app.nix
    ./freellmapi.nix
    ./searx.nix
    ./utils.nix
    ./tailscale.nix
    ./comfyui.nix
    ./kohya-ss.nix
    ./9router.nix
    ./headroom.nix
  ];
}

# vim: sts=2 sw=2 et ai
