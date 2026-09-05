set -euo pipefail

. $CLOUDFLARE

ip=$($IP route get 1.1.1.1 | $AWK '{print $7; exit}')
if ! $IPCALC -cs $ip; then
  echo "Invalid IP: $ip" >&2
  exit 1
fi

for domain in $DOMAIN *.$DOMAIN; do
  rc=0
  update_record $domain A $ip || rc=$?
  if [[ $rc -eq 2 ]]; then
    new_record $domain A $ip || true
  fi
done
