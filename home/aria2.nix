{
  lib,
  config,
  ...
}:
lib.mkIf config.programs.aria2.enable {
  programs.aria2.settings = {
    continue = true;
    max-connection-per-server = 8;
    split = 8;
    optimize-concurrent-downloads = true;
  };
}
