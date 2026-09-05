{
  mkShellNoCC,
  sing-box,
  gawk,
  coreutils,
  jq,
  curl,
  ipcalc,
  ...
}:
mkShellNoCC rec {
  HOSTNAME = "dog";
  DOMAIN = "${HOSTNAME}.zaelggk.com";
  SING_BOX = "${sing-box}/bin/sing-box";
  AWK = "${gawk}/bin/awk";
  TR = "${coreutils}/bin/tr";
  JQ = "${jq}/bin/jq";
  CURL = "${curl}/bin/curl";
  IPCALC = "${ipcalc}/bin/ipcalc";
}
