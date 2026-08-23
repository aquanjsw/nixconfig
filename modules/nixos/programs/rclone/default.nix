# You'll need deploy `/etc/rclone.conf` manually
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.rag.programs.rclone;
in
{
  options.rag.programs.rclone = {
    enable = lib.mkEnableOption "rclone";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.rclone ];
    systemd.mounts = [
      {
        enable = true;
        description = "Mount Google Drive";
        type = "rclone";
        what = "GoogleDrive:rclone";
        where = "/media/gdrive";
        options = "rw,nofail,_netdev,allow_other,args2env,config=/etc/rclone.conf,vfs-cache-mode=full,vfs-cache-min-free-space=10G";
        wantedBy = [ "multi-user.target" ];
      }
    ];
  };
}
