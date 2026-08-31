{
  pkgs,
  lib,
  self,
  ...
}:
let
  dirs = lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./.);
in
builtins.mapAttrs (dir: _: pkgs.callPackage ./${dir} { inherit self; }) dirs
