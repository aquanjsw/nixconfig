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
            binutils
          ]
          ++ lib.optionals (config.isBareMetal) [
            usbutils
            pciutils
          ]
        );
      environment.variables = {
      };
      # For PyTorch
      environment.memoryAllocator.provider = "jemalloc";

      programs.fish.enable = true;
      programs.nix-ld.enable = !config.isLimited; # For VSCode server
      programs.tmux.enable = true;
      programs.tmux.extraConfig = ''
        set -g mouse on
      '';

      services.openssh.enable = true;
      services.openssh.settings.PasswordAuthentication = false;
      systemd.services.sshd.serviceConfig = {
        OOMScoreAdjust = -1000;
      };

      # Disable tailscale's dns hijacking so that sing-box's tun can take over
      services.tailscale.extraUpFlags = [ "--accept-dns=false" ];

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
      services.earlyoom.enable = true;

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

      nixpkgs.overlays = [
        inputs.realcugan.overlays.default
        (final: prev: {
          rust-jemalloc-sys = prev.rust-jemalloc-sys.overrideAttrs (prevAttrs: {
            setupHook = pkgs.writeText "setup-hook.sh" ''
              export JEMALLOC_OVERRIDE="@out@/lib/libjemalloc_pic.a"
            '';
          });
        })
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
    ./freellmapi.nix
    ./searx.nix
    ./utils.nix
    ./comfyui.nix
    ./kohya-ss.nix
    ./9router.nix
    ./headroom.nix
  ];
}

# vim: sts=2 sw=2 et ai
