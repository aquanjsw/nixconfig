{
  pkgs,
  lib,
  self,
  ...
}:
let
  inherit (builtins)
    readDir
    mapAttrs
    ;
  inherit (pkgs)
    mkShellNoCC
    ;
  dirs = lib.filterAttrs (name: type: type == "directory") (readDir ./.);
in
(mapAttrs (dir: _: pkgs.callPackage ./${dir} { inherit self; }) dirs)
// {
  default = mkShellNoCC {
    packages = with pkgs; [
      sops
    ];
    CURL = "${pkgs.curl}/bin/curl";
    JQ = "${pkgs.jq}/bin/jq";
    GSETTINGS = "${pkgs.glib}/bin/gsettings";
  };
}
