{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    users.users.${config.rag.username} = {
      hashedPassword = "$y$j9T$Jj8kNaBhl9pdqRsFH.5Rw0$au/4czArJfGinqyBNueuzkt1QTO5mljFzAH9L5pVeR9";
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ]
      ++ lib.optional (config.virtualisation.libvirtd.enable) "libvirtd";
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = config.rag.ssh-keys;
      packages = with pkgs; [ ];
    };
    programs.fish.enable = true;
  };
}
