set -euo pipefail

. $CLOUDFLARE

ip=$($IP route get 1.1.1.1 | $AWK '{print $7; exit}')
if ! $IPCALC -cs $ip; then
  echo "Invalid IP: $ip" >&2
  exit 1
fi

for domain in $DOMAIN *.$DOMAIN; do
  sync_record $domain A $ip
done
