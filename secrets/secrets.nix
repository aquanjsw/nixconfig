let
  cat-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpzIcG2uFa8DIdHFgp9bHp9msFExzUYsilAmUnBTQuO";
  cat-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIENvcZL6L6QpDotsU6xgClQ4f16NhUOoCIFr7lOXOLVk";

  dog-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC08h/FP6qqvdfr9tdue9SRjB/auHP0c/15+3cp4xmiZ";
  dog-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/Nwn3AJ+MltE7EbwkqqhaQRqrhFB7nnwvsPP/TaF+U";

  bun-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDFLEmRonywzWXxU4xid8EHYJoBFZA5yhT1ZDgFRl0xn";
  bun-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9RA8v5OrIn/Vjt1hf0V+YQwrAQmFOHpuwfGaGteeb2";

  tur-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPBeG0JFEBS2I6vWEPBXPXPR22wtETzMktHuxzzpPz+F";
  tur-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMpgR/uiOXD2y6mn/OojBa/gyKId+x9i3qzQ2cee/eJq";

  rac-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAAouf1ZgGF1oatBjl2aK+ALMLRxsSH0rGZ3I1ZNi8u";
  rac-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTo2ziWT/vQMnHYow4xIUqtJ58AjyDst250uls5ckV3";

  users = [
    dog-user
    bun-user
    cat-user
    tur-user
    rac-user
  ];
  systems = [
    cat-system
    dog-system
    bun-system
    tur-system
    rac-system
  ];
in
{
  "caddy-env.age".publicKeys = users ++ [ cat-system ];
  "web-app-subscription-env.age".publicKeys = users ++ [ cat-system ];
  "vless-encryption.age".publicKeys = users ++ [ cat-system ];
  "vless-uuid-430.age".publicKeys = users ++ [ cat-system ];

  "tailscale-auth-key.age".publicKeys = users ++ systems;
  "huggingface-env.age".publicKeys = users ++ systems;
  "searx.age".publicKeys = users ++ systems;
  "freellmapi.age".publicKeys = users ++ systems;
  "syncthingGuiPassword.age".publicKeys = users ++ systems;
  "vless-uuid.age".publicKeys = users ++ systems;
  "reality-public-key.age".publicKeys = users ++ systems;
  "reality-private-key.age".publicKeys = users ++ systems;
  "clash-api-secret.age".publicKeys = users ++ systems;
  "beszel-agent-env.age".publicKeys = users ++ systems;
  "controller-secret.age".publicKeys = users ++ systems;
  "lan-auth.age".publicKeys = users ++ systems;
}

# vim: sts=2 sw=2 et ai
