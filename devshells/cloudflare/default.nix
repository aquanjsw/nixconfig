{
  mkShellNoCC,
  sing-box,
  ...
}:
mkShellNoCC rec {
  shellHook = ''
    . .dev/cloudflare.env
  '';
  SING_BOX = "${sing-box}/bin/sing-box";
  HOSTNAME = "dog";
  DOMAIN = "${HOSTNAME}.zaelggk.com";
}
