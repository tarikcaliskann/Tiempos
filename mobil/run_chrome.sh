#!/usr/bin/env bash
# Flutter Web — sabit port (Google OAuth "Authorized JavaScript origins" için).
# Google Cloud Console → OAuth Web client → şunu ekleyin:
#   http://localhost:9339
cd "$(dirname "$0")"
exec flutter run -d chrome --web-port=9339 "$@"
