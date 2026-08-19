#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

echo "========================================"
echo " BUILD"
echo "========================================"

echo
echo "==> Validando Docker Compose..."
docker compose config --quiet

echo
echo "==> Compilando backend..."
dotnet build "$ROOT_DIR/backend/Backend.sln"

echo
echo "==> Compilando frontend..."
(cd "$ROOT_DIR/frontend" && npm run build)

echo
echo "==> Construindo imagens..."
docker compose build

echo
echo "========================================"
echo " BUILD OK"
echo "========================================"
