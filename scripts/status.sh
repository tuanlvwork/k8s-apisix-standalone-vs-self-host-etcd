#!/usr/bin/env bash
set -euo pipefail

echo "=== Cluster Status ==="
echo ""
echo "--- Namespace: common (APISIX + etcd) ---"
echo ""
echo "Pods:"
kubectl get pods -n common -o wide
echo ""
echo "Services:"
kubectl get svc -n common
echo ""
echo "StatefulSets:"
kubectl get statefulsets -n common
echo ""
echo "Deployments:"
kubectl get deployments -n common
echo ""
echo "--- Namespace: app (Backend + Frontend) ---"
echo ""
echo "Pods:"
kubectl get pods -n app -o wide
echo ""
echo "Services:"
kubectl get svc -n app
echo ""
echo "Deployments:"
kubectl get deployments -n app
