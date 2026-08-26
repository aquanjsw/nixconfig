_: {
  config = {
    virtualisation.oci-containers.backend = "podman";
    virtualisation.podman = {
      defaultNetwork.settings = {
        dns_enabled = true;
      };
      autoPrune.enable = true;
    };
  };
}
