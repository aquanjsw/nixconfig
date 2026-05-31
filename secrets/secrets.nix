let
  dodo-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIW9TVyWzguSLNoL/PRKtYlCY0Weh1s5NZLPmSLikVHb";
  dodo-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJcbO0qdMXLqVo1um8dsJ5AsNop6f82DuHVgHfhmpV1";

  cat-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpzIcG2uFa8DIdHFgp9bHp9msFExzUYsilAmUnBTQuO";
  cat-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIENvcZL6L6QpDotsU6xgClQ4f16NhUOoCIFr7lOXOLVk";

  dog-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC08h/FP6qqvdfr9tdue9SRjB/auHP0c/15+3cp4xmiZ";
  dog-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/Nwn3AJ+MltE7EbwkqqhaQRqrhFB7nnwvsPP/TaF+U";

  panda-system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUOIOgWzKfzoL0HXGJ9et5zKPgr7hYvzIsTpfmQyM6R";
  panda-user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIByOu/Ck/Uyh7xl4B9xxkBtFUDL7Z6LAqVAHXCmGfNyp";

  users = [
    dodo-user
    dog-user
    panda-user
  ];
  systems = [
    dodo-system
    cat-system
    dog-system
    panda-system
  ];
in
{
  "caddy-env.age".publicKeys = users ++ [ cat-system ];
  "web-app-env.age".publicKeys = users ++ [ cat-system ];
  "vless-encryption.age".publicKeys = users ++ [ cat-system ];

  "syncthingGuiPassword.age".publicKeys = users ++ systems;
  "vless-uuid.age".publicKeys = users ++ systems;
  "reality-public-key.age".publicKeys = users ++ systems;
  "reality-private-key.age".publicKeys = users ++ systems;
  "clash-api-secret.age".publicKeys = users ++ systems;
  "beszel-agent-env.age".publicKeys = users ++ systems;
  "controller-secret.age".publicKeys = users ++ systems;
  "lan-auth.age".publicKeys = users ++ systems;
  "tailscale-auth-key.age".publicKeys = users ++ systems;
}

# vim: sts=2 sw=2 et ai
