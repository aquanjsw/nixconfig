let
  minimal-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIW9TVyWzguSLNoL/PRKtYlCY0Weh1s5NZLPmSLikVHb";
  minimal-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJcbO0qdMXLqVo1um8dsJ5AsNop6f82DuHVgHfhmpV1";
  vultr-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+XW58VGYhubgLiluoQIvN7gJoLlOxCMQmq6ff6Gk+U";
in {
  "caddy-env.age".publicKeys = [ minimal-user vultr-host ];
  "vless-uuid.age".publicKeys = [ minimal-user minimal-host vultr-host ];
  "reality-public-key.age".publicKeys = [ minimal-user minimal-host vultr-host ];
  "reality-private-key.age".publicKeys = [ minimal-user minimal-host vultr-host ];
  "rootDomain.age".publicKeys = [ minimal-user minimal-host vultr-host ];
  "bwh-domain.age".publicKeys = [ minimal-user minimal-host vultr-host ];
  "vultr-domain.age".publicKeys = [ minimal-user minimal-host vultr-host ];
  "clash-api-secret.age".publicKeys = [ minimal-user minimal-host vultr-host ];
}

# vim: sts=2 sw=2 et ai
