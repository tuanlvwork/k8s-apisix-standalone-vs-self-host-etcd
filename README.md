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
        │  cross-namespace DNS routing
        │
   ┌────┴─────────────────────┐
   │                          │
┌──▼───────────┐  ┌───────────▼──────────┐
│ product-svc  │  │    order-service      │   ← NestJS APIs
│ :3001        │  │    :3002              │     (app ns)
└──────────────┘  └──────────────────────┘
┌──────────────┐  ┌──────────────────────┐
│  storefront  │  │       admin          │   ← Next.js apps
│  :3000       │  │       :3000          │     (app ns)
└──────────────┘  └──────────────────────┘
```

**Namespaces:**
- `common` — APISIX gateway + etcd
- `app` — product-service, order-service, storefront, admin

**Routes (all prefixed `/services/testing-apisix`):**

| Path | Target service | Port |
|------|---------------|------|
| `/storefront/api/v1/products` | `product-service` API | 3001 |
| `/storefront/api/v1/orders` | `order-service` API | 3002 |
| `/admin/api/v1/products` | `product-service` API | 3001 |
| `/admin/api/v1/orders` | `order-service` API | 3002 |
| `/storefront/*` | `storefront` Next.js | 3000 |
| `/admin/*` | `admin` Next.js | 3000 |

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Node.js 20+ (for local development only)

## Quickstart

```bash
# 1. Start everything (Minikube + images + K8s deploy + wait)
./scripts/setup.sh

# 2. Port-forward APISIX gateway
./scripts/port-forward.sh

# 3. Test
BASE="http://localhost:9080/services/testing-apisix"
curl "$BASE/storefront/api/v1/products"
curl "$BASE/storefront/api/v1/orders"
open "$BASE/storefront/"
open "$BASE/admin/"
```

## Scripts Reference

| Script | Description |
|--------|-------------|
| `setup.sh` | Full setup: start Minikube, build images, deploy, wait for all pods |
| `deploy.sh [overlay]` | Apply Kustomize overlay (default: `dev`) |
| `build-images.sh` | Build all 4 app images inside Minikube's Docker daemon |
| `status.sh` | Show pod/service/deployment status across both namespaces |
| `logs.sh <component>` | Tail logs — accepts `etcd`, `apisix`, `product-service`, `order-service`, `storefront`, `admin` |
| `port-forward.sh [port]` | Forward APISIX proxy to `localhost:9080` (default) |
| `cleanup.sh [--stop-minikube]` | Delete both namespaces, optionally stop Minikube |

> **Note:** Route configuration is seeded by a K8s Job (`apisix-route-init`) that runs automatically on deploy.

## Project Structure (Kustomize)

```
├── apps/
│   ├── product-service/        # NestJS — products API  (:3001)
│   ├── order-service/          # NestJS — orders API    (:3002)
│   ├── storefront/             # Next.js — customer UI  (:3000)
│   └── admin/                  # Next.js — admin UI     (:3000)
├── k8s/
│   ├── base/
│   │   ├── common/             # etcd + APISIX (namespace: common)
│   │   │   ├── kustomization.yaml
│   │   │   ├── etcd.yaml
│   │   │   ├── apisix.yaml
│   │   │   └── apisix-route-init.yaml  # Job: seeds routes into etcd
│   │   └── app/                # 4 microservices (namespace: app)
│   │       ├── kustomization.yaml
│   │       ├── product-service.yaml
│   │       ├── order-service.yaml
│   │       ├── storefront.yaml
│   │       └── admin.yaml
│   └── overlays/
│       └── dev/                # dev environment
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
./scripts/status.sh                    # Check both namespaces
./scripts/logs.sh apisix               # APISIX logs (common ns)
./scripts/logs.sh product-service      # product-service logs (app ns)
./scripts/logs.sh storefront           # storefront logs (app ns)

# Re-run route seeding
kubectl delete job apisix-route-init -n common
kubectl apply -k k8s/overlays/dev/

# Full restart
./scripts/cleanup.sh && ./scripts/setup.sh
```
