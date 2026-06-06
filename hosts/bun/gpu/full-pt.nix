{
  config,
  lib,
  ...
}:
{
  options.gpu.full-pt = lib.mkEnableOption "Full passthrough for Intel i915 GPU";

  config = lib.mkIf config.gpu.full-pt {
    boot.kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      "vfio-pci.ids=8086:46d1"
    ];
    boot.kernelModules = [
      "vfio-pci"
      "vfio"
      "vfio_iommu_type1"
      "vfio-virqfd"
    ];
    boot.blacklistedKernelModules = [
      "i915"
    ];

    assertions = [
      {
        assertion = false;
        message = "Full passthrough for Intel i915 GPU does not work on QEMU/KVM.";
      }
    ];
  };
}
