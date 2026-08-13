{ lib, ... }:
{
  imports = [
    ./client
    ./server
  ];

  options.rag.services.sing-box = {
    role = lib.mkOption {
      type = lib.types.enum [
        "client"
        "server"
      ];
      description = "Role of the sing-box service (client or server)";
    };
  };
}
