{
  config,
  self,
  ...
}:
let
  home = config.users.users.${config.rag.username}.home;
  owner = config.users.users.${config.rag.username}.name;
  group = config.users.users.${config.rag.username}.group;
in
{
  config.sops.secrets = {
  };
}
