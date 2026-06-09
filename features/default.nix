{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
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
  ];

  options = {

    isOutside = lib.mkOption {
      default = false;
      description = "Whether the system is outside.";
    };

    isBareMetal = lib.mkOption {
      default = false;
      description = "Whether the system is running on bare metal.";
    };

    paths = lib.mkOption {
      default = {
        secrets = ../secrets;
      };
      readOnly = true;
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
    lib.mkMerge [
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
          packages =
            with pkgs;
            [
            ]
            ++ lib.optionals (config.virtualisation.oci-containers.containers != { }) [ podman-compose ];
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

        services.open-webui.port = 9080;
        services.open-webui.host = "0.0.0.0";

        programs.fish.enable = true;
        programs.nix-ld.enable = !config.isLimited;
        programs.mosh.enable = true;

        services.openssh.enable = true;
        services.openssh.settings.PasswordAuthentication = false;

        virtualisation.oci-containers.backend = "podman";
        virtualisation.podman = {
          dockerCompat = true;
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

      }

      (lib.mkIf config.web-app.enable {
        age.secrets.web-app-env.file = config.paths.secrets + "/web-app-env.age";
        web-app.envFile = config.age.secrets.web-app-env.path;
      })

    ];
}

# vim: sts=2 sw=2 et ai
