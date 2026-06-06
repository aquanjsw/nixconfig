{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.gpu.sriov = lib.mkEnableOption "SR-IOV support for Intel i915 GPU";

  config = lib.mkIf config.gpu.sriov {
    systemd.services.create-vfs = {
      description = "Create virtual functions for Intel i915 GPU";
      after = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe pkgs.bash} -c 'echo 7 > /sys/bus/pci/devices/0000:00:02.0/sriov_numvfs'";
      };
    };
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:00:02.[1-7]", ATTR{vendor}=="0x8086", ATTR{device}=="0x46d1", DRIVER!="vfio-pci", RUN+="${lib.getExe pkgs.bash} -c 'echo \''$kernel > /sys/bus/pci/devices/\''$kernel/driver/unbind; echo vfio-pci > /sys/bus/pci/devices/\''$kernel/driver_override; modprobe vfio-pci; echo \''$kernel > /sys/bus/pci/drivers/vfio-pci/bind'"
    '';
    boot.extraModulePackages = [ pkgs.i915-sriov ];
    boot.kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      "i915.enable_guc=3"
      "i915.max_vfs=7"
      "module_blacklist=xe"
    ];
    boot.kernelModules = [ "vfio-pci" ];
    boot.blacklistedKernelModules = [ "xe" ];
  };
}
