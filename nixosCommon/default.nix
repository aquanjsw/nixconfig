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
    ./caddy
    ./derper.nix
    ./beszel
    ./syncthing.nix
    ./dnf.nix
  ];

  options = {

    isOutside = lib.mkEnableOption "Whether the system is outside.";

    isBareMetal = lib.mkEnableOption "Whether the system is running on bare metal.";

    domain = lib.mkOption {
      default = "zaelggk.com";
      readOnly = true;
    };
  };

  config =
    let
      ssh-keys = lib.strings.splitString "\n" (lib.strings.trim (builtins.readFile inputs.ssh-keys));
    in
    lib.mkMerge [
      {
        users.users.${config.user} = {
          isNormalUser = true;
          extraGroups = [
            "wheel"
          ];
          shell = pkgs.fish;
          openssh.authorizedKeys.keys = ssh-keys;
          packages = with pkgs; [
          ];
        };
        users.users.root.openssh.authorizedKeys.keys = ssh-keys;

        environment.systemPackages = with pkgs; [
        ];

        programs.fish.enable = true;
        programs.nix-ld.enable = !config.isLimited;

        services.openssh.enable = true;
        services.openssh.settings.PasswordAuthentication = false;

        networking.networkmanager.enable = true;
        networking.iproute2.enable = true;
        networking.firewall.enable = false;
        networking.nftables.enable = true;

        zramSwap.enable = true;
        zramSwap.memoryPercent = lib.mkIf config.isLimited 100;

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
