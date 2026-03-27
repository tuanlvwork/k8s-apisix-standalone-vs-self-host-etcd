#!/usr/bin/env bash
set -euo pipefail

LOCAL_PORT="${1:-9080}"

# ─── Kill stale port-forwards on the same ports ──────────────────────────────
# Prevents "address already in use" when the script is re-run.
echo "▶ Cleaning up any existing APISIX port-forwards..."
pkill -f "kubectl port-forward svc/apisix" 2>/dev/null && sleep 1 || true

# Also release ports directly if something else grabbed them
for port in "$LOCAL_PORT" 9180; do
  lsof -ti tcp:"$port" 2>/dev/null | xargs -r kill -9 2>/dev/null || true
done

echo "▶ Port-forwarding APISIX services"
echo "  - Storefront: http://localhost:$LOCAL_PORT/services/storefront/"
echo "  - Admin:      http://localhost:$LOCAL_PORT/services/admin/"
echo "  - Products:   http://localhost:$LOCAL_PORT/services/storefront/api/v1/products"
echo "  - Orders:     http://localhost:$LOCAL_PORT/services/storefront/api/v1/orders"
echo "  - Admin API:  http://localhost:9180/apisix/admin/routes"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Forward proxy and admin API in parallel
kubectl port-forward svc/apisix "$LOCAL_PORT:9080" -n common &
kubectl port-forward svc/apisix 9180:9180 -n common &

wait
