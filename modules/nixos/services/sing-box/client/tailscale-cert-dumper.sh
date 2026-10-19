#!/usr/bin/env bash

set -euo pipefail

echo "Generating Tailscale certificate and key files..."

for _ in {1..10}; do
  $SING_BOX api tailscale certificate export \
    --cert-file $CERT_FILE --key-file $KEY_FILE $DOMAIN >&1 || true

  if [ -f "$CERT_FILE" ] && [ -f "$KEY_FILE" ]; then
    echo "Certificate and key files generated successfully."
    chmod o+r $CERT_FILE $KEY_FILE
    exit 0
  fi

  sleep 1
done

echo "Failed to generate certificate and key files after 10 attempts."
exit 1
