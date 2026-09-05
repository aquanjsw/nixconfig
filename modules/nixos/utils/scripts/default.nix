{ lib, ... }:
let
  fnames = builtins.attrNames (
    lib.filterAttrs (name: type: type == "regular" && (lib.hasSuffix ".sh" name)) (builtins.readDir ./.)
  );
  namePathMap = builtins.listToAttrs (
    map (fname: {
      name = lib.removeSuffix ".sh" fname;
      value = ./${fname};
    }) fnames
  );
in
{
  options.rag.utils.scripts = lib.mkOption {
    default = namePathMap;
    readOnly = true;
  };
}
