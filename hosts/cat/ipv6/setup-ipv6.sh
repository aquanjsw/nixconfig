set -euo pipefail

if ! $PING -c 1 -W 1 2606:4700:4700::1111 &>/dev/null; then
  echo "No IPv6 connectivity"
  echo "Cleaning up"
  $IP route del ::/0 dev ipv6net &>/dev/null || true
  $IP tunnel del ipv6net &>/dev/null || true
else
  echo "IPv6 is already configured"
  exit 0
fi

local_ip=$($IP route get 1.1.1.1 | $AWK '{print $7; exit}')

if ! $IPCALC -cs $local_ip; then
  echo "Invalid IP: $local_ip" >&2
  exit 1
fi

$IP tunnel add ipv6net mode sit local $local_ip remote 45.32.66.87 ttl 255
$IP link set ipv6net up
$IP addr add 2607:8700:5500:5b28::2/64 dev ipv6net
$IP route add ::/0 dev ipv6net

echo "IPv6 is now configured"
