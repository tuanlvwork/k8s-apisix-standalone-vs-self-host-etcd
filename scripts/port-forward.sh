#!/usr/bin/env bash
set -euo pipefail

LOCAL_PORT="${1:-9080}"

echo "▶ Port-forwarding APISIX services"
echo "  - Proxy:      http://localhost:$LOCAL_PORT/"
echo "  - Backend:    http://localhost:$LOCAL_PORT/api/health"
echo "  - Dashboard:  http://localhost:9000/  (admin/admin)"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Forward both proxy and dashboard in parallel
kubectl port-forward svc/apisix "$LOCAL_PORT:9080" -n common &
kubectl port-forward svc/apisix-dashboard 9000:9000 -n common &

wait
