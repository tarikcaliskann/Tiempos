#!/usr/bin/env bash
# Yerel backend (http://localhost:8080) + Chrome sabit port 9339
# Google Web: kök .env içinde GOOGLE_CLIENT_ID varsa otomatik --dart-define ile verilir.
# Cloud Console → OAuth Web client → Yetkili JavaScript kökenleri: http://localhost:9339
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GDEF=()
if [[ -f "$ROOT/.env" ]]; then
  line="$(grep -E '^GOOGLE_CLIENT_ID=' "$ROOT/.env" | tail -1 || true)"
  if [[ -n "${line}" ]]; then
    # shellcheck disable=SC2163
    export "$line"
  fi
fi
if [[ -n "${GOOGLE_CLIENT_ID:-}" ]]; then
  GDEF+=(--dart-define="GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID")
fi

exec flutter run -d chrome --web-port=9339 \
  --dart-define=API_BASE_URL="${API_BASE_URL:-http://localhost:8080}" \
  "${GDEF[@]}" "$@"
