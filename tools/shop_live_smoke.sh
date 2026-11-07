#!/usr/bin/env bash
# 真实 HTTP 冒烟（本机 SSFluxServer）。勿把 token 写入 stdout。
set -euo pipefail
BASE="${SS_API_BASE_URL:-http://127.0.0.1:8080/api/v1}"
LOG="${1:-/tmp/shop-live-smoke.log}"

: "${LIVE_SHOP_EMAIL:?set LIVE_SHOP_EMAIL}"
: "${LIVE_SHOP_PASSWORD:?set LIVE_SHOP_PASSWORD}"

{
  echo "=== shop live smoke $(date -u +%FT%TZ) ==="
  for path in shop/home shop/categories/l1 'shop/products?limit=2' shop/cart shop/me; do
    code=$(curl -sS -o /tmp/r.json -w "%{http_code}" "$BASE/$path")
    echo "GET $path -> $code ($(wc -c </tmp/r.json) bytes)"
  done
  curl -sS -X POST "$BASE/auth/login" -H 'Content-Type: application/json' \
    -d "{\"email\":\"$LIVE_SHOP_EMAIL\",\"password\":\"$LIVE_SHOP_PASSWORD\"}" \
    -o /tmp/login.json
  echo "POST auth/login -> $(python3 -c "import json;print('ok' if 'accessToken' in json.load(open('/tmp/login.json')) else 'fail')")"
  TOKEN=$(python3 -c "import json;print(json.load(open('/tmp/login.json'))['accessToken'])")
  code=$(curl -sS -o /tmp/cart.json -w "%{http_code}" -H "Authorization: Bearer $TOKEN" "$BASE/shop/cart")
  echo "GET shop/cart authed -> $code totals=$(python3 -c "import json;c=json.load(open('/tmp/cart.json'));print(c.get('selectedTotalCents'),c.get('badgeCount'))")"
} | tee "$LOG"
