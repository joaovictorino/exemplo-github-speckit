#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

cleanup() {
    echo
    echo "==> Encerrando ambiente de validação..."
    docker compose down --remove-orphans
}

trap cleanup EXIT

echo "========================================"
echo " VALIDATION"
echo "========================================"

echo
echo "==> 1/4 Validando Docker Compose..."
docker compose config --quiet

echo
echo "==> 2/4 Executando build..."
"$ROOT_DIR/scripts/build.sh"

echo
echo "==> 3/4 Inicializando aplicação..."
docker compose up -d

echo
echo "==> Aguardando backend..."

MAX_ATTEMPTS=30
ATTEMPT=1

until curl -fsS http://localhost/api/health >/dev/null 2>&1; do
    if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
        echo
        echo "Backend não ficou saudável."
        echo
        echo "==> Containers:"
        docker compose ps

        echo
        echo "==> Logs:"
        docker compose logs

        exit 1
    fi

    sleep 2
    ATTEMPT=$((ATTEMPT + 1))
done

echo "Backend saudável."

echo
echo "==> 4/4 Health check..."
curl -fsS http://localhost/api/health

echo
echo
echo "========================================"
echo " VALIDATION OK"
echo "========================================"
