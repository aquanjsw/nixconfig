{
  disko.devices = {
    disk = {
      ssd = {
        device = "/dev/disk/by-id/nvme-APS-SE20G-1T_SG01C20513WL";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            lvm_pv = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "ssd_vg";
              };
            };
          };
        };
      };
      hdd_6t = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST6000NM0115-1YZ110_ZAD8400Z";
        content = {
          type = "lvm_pv";
          vg = "data_vg";
        };
      };
      hdd_2t_a = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST2000DM006-2DM164_Z4Z9GH8X";
        content = {
          type = "lvm_pv";
          vg = "data_vg";
        };
      };
    };
    lvm_vg = {
      ssd_vg = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
          cache_lv = {
            size = "300G";
          };
        };
      };
      data_vg = {
        type = "lvm_vg";
        lvs = {
          data_lv = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/data";
            };
          };
        };
      };
    };
  };
}