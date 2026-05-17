{
  description = "Django web app";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      packageOverrides = self: super: {
        django-hosts = super.buildPythonPackage rec {
          pname = "django-hosts";
          version = "7.0.0";
          src = super.fetchPypi {
            pname = "django_hosts";
            inherit version;
            sha256 = "sha256-CABrwJ9a9pY4chztBlfyQESDWiKmCHMu4QBK3JyV+3w=";
          };
          pyproject = true;
          build-system = [
            pkgs.python3Packages.setuptools
            pkgs.python3Packages.setuptools-scm
          ];
        };
      };
      python = pkgs.python3.override {
        inherit packageOverrides;
        self = python;
      };
      pythonEnv = python.withPackages (ps: [
        ps.django-hosts
        ps.django
        ps.gunicorn
      ]);
    in
    {
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [ pythonEnv ];
        DEBUG = "1";
      };

      packages.${system}.default =
        with pkgs.lib;
        pkgs.stdenv.mkDerivation {
          name = "web-app";
          src = fileset.toSource {
            root = ./.;
            fileset = fileset.unions [
              ./web_app
              ./subalter
            ];
          };
          installPhase = ''
            mkdir -p $out/bin $out/lib
            cp -r web_app subalter $out/lib/
            makeWrapper ${getBin pythonEnv}/bin/gunicorn $out/bin/web-app \
              --add-flags "--chdir $out/lib -b 127.0.0.1:\''${PORT} web_app.wsgi"
          '';
          nativeBuildInputs = [ pkgs.makeWrapper ];
          buildInputs = [ pythonEnv ];
        };

      nixosModules.default =
        {
          lib,
          config,
          pkgs,
          ...
        }:
        with lib;
        let
          cfg = config.web-app;
        in
        {
          options.web-app = {
            enable = mkEnableOption "web app";
            package = mkOption {
              type = types.package;
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
              description = ''
                The package to use for the web app.
                Only x86_64-linux is tested at the moment.
              '';
            };
            port = mkOption {
              type = types.port;
              default = 8000;
              description = "The port to run the web app on.";
            };
            subscription.mihomo = {
              configPath = mkOption {
                type = types.str;
                example = "/run/secrets/mihomo.json";
                description = "The path to the mihomo subscription config file.";
              };
              urlPath = mkOption {
                type = types.str;
                example = "mihomo.json";
                description = "The URL path for the mihomo subscription.";
              };
            };
            subscription.sing-box = {
              configPath = mkOption {
                type = types.str;
                example = "/run/secrets/sing-box.json";
                description = "The path to the sing-box subscription config file.";
              };
              urlPath = mkOption {
                type = types.str;
                example = "sing-box.json";
                description = "The URL path for the sing-box subscription.";
              };
            };
            subscription.domain = mkOption {
              type = types.str;
              description = "Full domain will be <subdomain>.<config.domain>";
            };
            envFile = mkOption {
              type = types.str;
              example = "/run/secrets/env";
              description = ''
                The path to the environment file with content like:
                ```
                SECRET_KEY=your_secret_key
                ```
              '';
            };
          };

          config = mkIf config.web-app.enable {
            systemd.services.web-app = {
              description = "web app";
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              environment = {
                PORT = builtins.toString cfg.port;
                MIHOMO_CONFIG_PATH = cfg.subscription.mihomo.configPath;
                SINGBOX_CONFIG_PATH = cfg.subscription.sing-box.configPath;
                MIHOMO_URL_PATH = cfg.subscription.mihomo.urlPath;
                SINGBOX_URL_PATH = cfg.subscription.sing-box.urlPath;
                SUBSCRIPTION_DOMAIN = cfg.subscription.domain;
                DOMAIN = config.domain;
              };
              serviceConfig = {
                EnvironmentFile = [ cfg.envFile ];
                Restart = "always";
                ExecStart = "${cfg.package}/bin/web-app";
              };
            };
          };
        };
    };
}
