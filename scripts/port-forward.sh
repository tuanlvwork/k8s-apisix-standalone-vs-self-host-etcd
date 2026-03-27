#!/usr/bin/env bash
set -euo pipefail

LOCAL_PORT="${1:-9080}"

echo "▶ Port-forwarding APISIX services"
echo "  - Proxy:      http://localhost:$LOCAL_PORT/services/testing-apisix/"
echo "  - Storefront: http://localhost:$LOCAL_PORT/services/testing-apisix/storefront/"
echo "  - Admin:      http://localhost:$LOCAL_PORT/services/testing-apisix/admin/"
echo "  - Products:   http://localhost:$LOCAL_PORT/services/testing-apisix/storefront/api/v1/products"
echo "  - Orders:     http://localhost:$LOCAL_PORT/services/testing-apisix/storefront/api/v1/orders"
echo "  - Admin API:  http://localhost:9180/apisix/admin/routes"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Forward proxy and admin API in parallel
kubectl port-forward svc/apisix "$LOCAL_PORT:9080" -n common &
kubectl port-forward svc/apisix 9180:9180 -n common &

wait
