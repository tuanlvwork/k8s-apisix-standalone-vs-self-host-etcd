# APISIX Standalone + Self-Hosted etcd Sandbox

A local development sandbox for learning APISIX as an API gateway with a self-hosted etcd cluster, running on Minikube.

## Architecture

```
Internet (localhost via port-forward)
        │
    ┌───▼───┐
    │ APISIX │  ← API Gateway (common ns, port 9080)
    └───┬───┘
        │  reads config from etcd (common ns)
    ┌───▼───┐
    │  etcd  │  ← Configuration store (common ns)
    └───────┘
        │
   cross-namespace DNS routing
        │
   ┌────┴────┐
   │         │
┌──▼──┐  ┌──▼───┐
│ BE  │  │  FE  │    ← app namespace
└─────┘  └──────┘
NestJS    NextJS
:3001     :3000
```

**Namespaces:**
- `common` — APISIX gateway + etcd
- `app` — backend + frontend

**Routes (cross-namespace DNS):**
- `/api/*` → `backend-svc.app:3001`
- `/*` → `frontend-svc.app:3000`

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Node.js 20+ (for local development only)

## Quickstart

```bash
# 1. Start everything
./scripts/setup.sh

# 2. Port-forward APISIX gateway
./scripts/port-forward.sh

# 3. Test
curl http://localhost:9080/api/health
open http://localhost:9080/
```

## Scripts Reference

| Script | Description |
|--------|-------------|
| `setup.sh` | Full setup: start Minikube, build images, deploy, wait for routes |
| `deploy.sh` | Apply Kustomize overlay (`kubectl apply -k`) |
| `build-images.sh` | Build Docker images in Minikube's Docker |
| `status.sh` | Show pod/service status across both namespaces |
| `logs.sh <component>` | Tail logs (auto-resolves namespace) |
| `port-forward.sh` | Forward APISIX to localhost:9080 |
| `cleanup.sh [--stop-minikube]` | Delete both namespaces, optionally stop Minikube |

> **Note:** Route configuration is now a K8s Job (`apisix-route-init`) that runs automatically on deploy.

## Project Structure (Kustomize)

```
├── apps/
│   ├── backend/                    # NestJS API
│   └── frontend/                   # NextJS app
├── k8s/
│   ├── base/
│   │   ├── common/                 # etcd + APISIX (namespace: common)
│   │   │   ├── kustomization.yaml
│   │   │   ├── etcd.yaml
│   │   │   ├── apisix.yaml
│   │   │   └── apisix-route-init.yaml  # Job: seeds routes
│   │   └── app/                    # backend + frontend (namespace: app)
│   │       ├── kustomization.yaml
│   │       ├── backend.yaml
│   │       └── frontend.yaml
│   └── overlays/
│       └── dev/                    # dev environment
│           ├── kustomization.yaml  # ← entry point
│           └── namespace.yaml
├── scripts/
└── README.md
```

**Kustomize usage:**

```bash
# Preview rendered manifests
kubectl kustomize k8s/overlays/dev/

# Deploy
kubectl apply -k k8s/overlays/dev/

# Or use the script (defaults to dev overlay)
./scripts/deploy.sh
```

## Troubleshooting

```bash
./scripts/status.sh              # Check both namespaces
./scripts/logs.sh apisix         # APISIX logs (common ns)
./scripts/logs.sh backend        # Backend logs (app ns)
kubectl delete job apisix-route-init -n common  # Re-run route init
kubectl apply -k k8s/overlays/dev/              # (Job recreated)
./scripts/cleanup.sh && ./scripts/setup.sh      # Full restart
```
