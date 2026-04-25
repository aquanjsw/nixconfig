{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let 
  ssh-keys = lib.strings.splitString "\n"
    (lib.strings.trim (builtins.readFile inputs.ssh-keys));
in {

  imports = [ ./home-manager.nix ];

  users.users.rag = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = ssh-keys;
    packages = with pkgs; [ ];
  };
  users.users.root.openssh.authorizedKeys.keys = ssh-keys;

  environment.variables.EDITOR = "vim";
  environment.systemPackages = with pkgs; [
    tree
    gh
    xdg-utils
    dig
    nodejs
    netcat
    curl
    zellij
    ranger
    gnumake
    inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];

  programs.fish.enable = true;
  programs.htop.enable = true;
  programs.git.enable = true;
  programs.vim.enable = true;
  programs.vim.defaultEditor = true;
  programs.nix-ld.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  networking.networkmanager.enable = true;
  networking.iproute2.enable = true;
  networking.firewall.enable = false;
  networking.nftables.enable = true;

  zramSwap.enable = true;

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.settings.substituters = lib.mkDefault [ "https://mirrors.cernet.edu.cn/nix-channels/store" ];
  nix.gc.automatic = true;
}

# vim: sts=2 sw=2 et ai
