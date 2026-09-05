# Required envs:
# CLOUDFLARE_API_TOKEN ZONE_ID JQ CURL

set -euo pipefail

is_tailnetip() {
  if [[ $1 != 100.* ]]; then
    return 1
  fi
  return 0
}

echo "Querying tailnet IP through sing-box api..."

for _ in {1..10}; do
  ts_ip=$($SING_BOX api tailscale peer show $HOSTNAME 2>/dev/null | grep IPs \
    | $AWK '{print $2}' | $TR -d ',')
  if is_tailnetip "$ts_ip"; then
    break
  fi
  sleep 1
done

if [[ -z "$ts_ip" ]]; then
  echo "Failed to query tailnet IP through sing-box api" >&2
  exit 1
fi

echo "$HOSTNAME -> $ts_ip"

result_records=$($CURL -sH "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records 2>/dev/null)

# Check if a result is successful
# Usage: is_success "$result"
is_success() {
  if [[ -z $(echo "$1" | $JQ 'select(.success == true)') ]]; then
    return 1
  fi
  return 0
}

if ! is_success "$result_records"; then
  echo "Failed to fetch DNS records: $result_records" >&2
  exit 1
fi

# Clean up leftover ACME TXT records
acme_record_ids=$(echo "$result_records" | $JQ -r '.result[]?
  | select(.type == "TXT" and (.name | startswith("_acme-challenge."))) | .id')

for record_id in $acme_record_ids; do
  if [[ -n "$record_id" ]]; then
    result=$($CURL -sX DELETE -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$record_id \
      2>/dev/null)
    if is_success "$result"; then
      echo "Cleaned up leftover ACME TXT record: $record_id"
    else
      echo "Warning: Failed to delete ACME TXT record $record_id: $result" >&2
    fi
  fi
done

for domain in $DOMAIN *.$DOMAIN; do
  record=$(echo "$result_records" | $JQ --arg domain $domain '
    .result[]? | select(.name == $domain and .type == "A")')

  # No record found, create a new one
  if [[ -z "$record" ]]; then
    result=$($CURL -sH 'Content-Type: application/json' \
      https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      -d "{
            \"name\": \"$domain\",
            \"type\": \"A\",
            \"content\": \"$ts_ip\"
          }" 2>/dev/null)
    if ! is_success "$result"; then
      echo "Failed to create DNS record: $result" >&2
      exit 1
    fi
    echo "Created DNS record: $domain -> $ts_ip"

  # Record found but content doesn't match, update it
  elif [[ -z $(echo "$record" | $JQ --arg ts_ip "$ts_ip" '
    select(.content == $ts_ip)') ]]; then
    record_id=$(echo "$record" | $JQ -r '.id')
    result=$($CURL -sX PATCH -H 'Content-Type: application/json' \
      https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$record_id \
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
