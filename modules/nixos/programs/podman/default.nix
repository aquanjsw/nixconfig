{ lib, ... }: {
  config = {
    virtualisation.oci-containers.backend = "podman";
    virtualisation.podman = {
      enable = lib.mkDefault true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
      autoPrune.enable = true;
    };
  };
}
