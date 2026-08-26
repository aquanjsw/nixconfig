{ config, lib, ... }:
let
  cfg = config.services.code-server;
in
{
  config = lib.mkIf cfg.enable {
    services.code-server = {
      host = lib.mkDefault "0.0.0.0";
      disableUpdateCheck = true;
      hashedPassword = "$argon2i$v=19$m=4096,t=3,p=1$ZlYwNWhOdGI0dVFyd2toaC84ZjVlRnh0ektBPQ$BQWt7gYSIAGpmoyTY7GcUu02ZHRXKuqBA9hVUW4tcG0";
      user = config.rag.username;
    };
  };
}
