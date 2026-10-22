set -euo pipefail

FALLBACK_LAT=34.2342342
FALLBACK_LON=108.9044959

get_coords() {
  local coords
  local suffix

  if [[ -n "${IPINFO_TOKEN:-}" ]]; then
    suffix="?token=${IPINFO_TOKEN}"
  else
    suffix=""
  fi

  for _ in {1..3}; do
    coords=$(curl -s --connect-timeout 3 "https://ipinfo.io/loc${suffix}" 2>/dev/null || true)
    if [[ "$coords" =~ ^-?[0-9]+\.[0-9]+,[0-9]+\.[0-9]+$ ]]; then
      echo "$coords"
      return 0
    fi
  done
  echo "Failed to get coordinates from ipinfo.io, using fallback coordinates" >&2
  echo "${FALLBACK_LAT},${FALLBACK_LON}"
}

coords="$(get_coords)"

for _ in {1..3}; do
  result=$(curl -s --connect-timeout 3 "https://api.sunrise-sunset.org/v2?lat=${coords%,*}&lng=${coords#*,}&time_format=unix" 2>/dev/null || true)
  if [[ "$result" == *"sunrise"* ]]; then
    sunrise=$(echo "$result" | jq -r '.sunrise')
    sunset=$(echo "$result" | jq -r '.sunset')
    break
  fi
done

if [[ -z "${sunrise:-}" || -z "${sunset:-}" ]]; then
  echo "Failed to get sunrise/sunset times" >&2
  exit 1
fi

now=$(date +%s)
if (( now >= sunrise && now < sunset )); then
  color_scheme='prefer-light'
else
  color_scheme='prefer-dark'
fi

if ! gsettings set org.gnome.desktop.interface color-scheme "$color_scheme"; then
  echo "Failed to set color scheme" >&2
  exit 1
fi
