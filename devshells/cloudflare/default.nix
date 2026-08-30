{
  mkShellNoCC,
  sing-box,
  gawk,
  coreutils,
  jq,
  curl,
  ...
}:
mkShellNoCC rec {
  shellHook = ''
    . .dev/cloudflare.env
  '';
  HOSTNAME = "dog";
  DOMAIN = "${HOSTNAME}.zaelggk.com";
  ZONE_ID = "93b98e5d2505428a7bda13476f8b179d";
  SING_BOX = "${sing-box}/bin/sing-box";
  AWK = "${gawk}/bin/awk";
  TR = "${coreutils}/bin/tr";
  JQ = "${jq}/bin/jq";
  CURL = "${curl}/bin/curl";
}
