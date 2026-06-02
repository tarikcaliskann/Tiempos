#!/usr/bin/env bash
# Yerel API: Postgres (Docker :5433) + Spring Boot :8080
# Kullanım (repo kökünden): ./scripts/start-local-backend.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! docker info >/dev/null 2>&1; then
  echo "Docker çalışmıyor; Docker Desktop'ı açın." >&2
  exit 1
fi

docker start tiempos-postgres 2>/dev/null \
  || docker compose up -d db

echo "Postgres hazır olana kadar bekleniyor..."
for _ in $(seq 1 30); do
  if docker exec tiempos-postgres pg_isready -U timebank_user -d timebank >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

cd "$ROOT/backend"
export SPRING_PROFILES_ACTIVE=local
export SPRING_DATASOURCE_URL='jdbc:postgresql://localhost:5433/timebank'
export SPRING_DATASOURCE_USERNAME=timebank_user
export SPRING_DATASOURCE_PASSWORD='1234'
export JWT_SECRET="${JWT_SECRET:-local-dev-jwt-secret-at-least-32-chars-long}"

# Kök .env içinden yalnızca GOOGLE_CLIENT_ID (Google Web + backend tokeninfo aud için)
if [[ -f "$ROOT/.env" ]]; then
  line="$(grep -E '^GOOGLE_CLIENT_ID=' "$ROOT/.env" | tail -1 || true)"
  if [[ -n "${line}" ]]; then
    export "$line"
    echo "GOOGLE_CLIENT_ID .env dosyasından yüklendi."
  fi
fi

echo "Spring Boot başlıyor: http://localhost:8080"
exec ./mvnw spring-boot:run
