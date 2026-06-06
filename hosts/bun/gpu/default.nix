{
  config,
  ...
}:
{
  imports = [
    ./full-pt.nix
    ./sriov.nix
  ];

  config.assertions = [
    {
      assertion = !(config.gpu.full-pt && config.gpu.sriov);
      message = "Full passthrough and SR-IOV cannot be enabled at the same time. Please choose one.";
    }
  ];
}
