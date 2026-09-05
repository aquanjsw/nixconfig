# Check if a result is successful
# 1: Result to check
is_success() {
  if [[ -z $(echo "$1" | $JQ 'select(.success == true)') ]]; then
    return 1
  fi
  return 0
}

# Get all DNS records for the zone
# 1: Output variable name
get_records() {
  local -n out=$1
  out=$($CURL -sH "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records 2>/dev/null)
  if ! is_success "$out"; then
    echo "Failed to fetch DNS records: $out" >&2
    return 1
  fi
}

# Create a new DNS record
# 1: Domain name
# 2: Record type
# 3: Content
# RetCode:
# 0: Success
# 1: Failure
# 2: Record already exists
new_record() {
  local domain=$1
  local type=$2
  local content=$3
  local records

  get_records records || return 1

  record=$(echo "$records" | $JQ --arg domain $domain --arg type $type '
    .result[]? | select(.name == $domain and .type == $type)')

  if [[ -z "$record" ]]; then
    result=$($CURL -sH 'Content-Type: application/json' \
      https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      -d "{
            \"name\": \"$domain\",
            \"type\": \"$type\",
            \"content\": \"$content\"
          }" 2>/dev/null)
    if ! is_success "$result"; then
      echo "Failed to create DNS record: $domain -> $content" >&2
      return 1
    fi
    echo "Created DNS record: $domain -> $content"
  else
    echo "DNS record already exists: $domain -> $content"
    return 2
  fi
}

# Update an existing DNS record
# 1: Domain name
# 2: Record type
# 3: Content
# RetCode:
# 0: Success
# 1: Failure
# 2: Record does not exist
update_record() {
  local domain=$1
  local type=$2
  local content=$3

  local records
  get_records records || return 1

  record=$(echo "$records" | $JQ --arg domain $domain --arg type $type '
    .result[]? | select(.name == $domain and .type == $type)')

  if [[ -z "$record" ]]; then
    echo "DNS record does not exist: $domain -> $content"
    return 2
  fi

  if [[ $(echo "$record" | $JQ --arg content "$content" 'select(.content == $content)') ]]; then
    echo "DNS record already exists: $domain -> $content"
    return 0
  fi

  local id=$(echo "$record" | $JQ -r '.id')
  result=$($CURL -sH 'Content-Type: application/json' -X PATCH \
    https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$id \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -d "{
          \"name\": \"$domain\",
          \"type\": \"$type\",
          \"content\": \"$content\"
        }" 2>/dev/null)
  if ! is_success "$result"; then
    echo "Failed to update DNS record: $domain -> $content" >&2
    return 1
  fi
  echo "Updated DNS record: $domain -> $content"
}
