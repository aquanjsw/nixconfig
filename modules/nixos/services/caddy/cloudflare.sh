set -euo pipefail

is_valid_ip() {
  if [[ $1 != 100* ]]; then
    return 1
  fi
  return 0
}

# Wait for a valid tailnet IP
for _ in {1..30}; do
  ts_ip=$($SING_BOX api tailscale peer show $HOSTNAME 2>/dev/null | grep IPs | $AWK '{print $2}' | $TR -d ',')
  if is_valid_ip "$ts_ip"; then
    break
  fi
  sleep 1
done

result_records=$($CURL -s https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN")

# Check if the result is a success
# Usage: is_success "$result"
# Returns 0 if the result is a success, 1 otherwise
is_success() {
  if [[ -z $(echo "$1" | $JQ 'select(.success == true)') ]]; then
    return 1
  fi
  return 0
}

for domain in $DOMAIN *.$DOMAIN; do
  record=$(echo "$result_records" | $JQ --arg domain $domain '.result[]? | select(.name == $domain and .type == "A")')

  # No record found, create a new one
  if [[ -z "$record" ]]; then
    result=$($CURL -s https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      -d "{
            \"name\": \"$domain\",
            \"type\": \"A\",
            \"content\": \"$ts_ip\"
          }")
    if ! is_success "$result"; then
      echo "Failed to create DNS record: $result" >&2
      exit 1
    fi
    echo "Created DNS record: $domain -> $ts_ip"

  # Record found but content doesn't match, update it
  elif [[ -z $(echo "$record" | $JQ --arg ts_ip "$ts_ip" 'select(.content == $ts_ip)') ]]; then
    record_id=$(echo "$record" | $JQ -r '.id')
    result=$($CURL -s https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$record_id \
        -X PATCH \
        -H 'Content-Type: application/json' \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -d "{
              \"name\": \"$domain\",
              \"type\": \"A\",
              \"content\": \"$ts_ip\"
            }")
    if ! is_success "$result"; then
      echo "Failed to update DNS record: $result" >&2
      exit 1
    fi
    echo "Updated DNS record: $domain -> $ts_ip"
  fi
done

exit 0
