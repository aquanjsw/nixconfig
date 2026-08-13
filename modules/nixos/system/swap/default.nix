{ config, lib, ... }:
let
  cfg = config.rag.system.swap;
in
{
  options.rag.system.swap.fileSize = lib.mkOption {
    default = 4 * 1024;
  };

  config = {
    zramSwap.enable = true;
    zramSwap.priority = 100;

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = cfg.fileSize;
        priority = 5;
      }
    ];
  };
}
