# APISIX Standalone + Self-Hosted etcd Sandbox on Minikube

Build a local development sandbox to learn APISIX as an API gateway with a self-hosted etcd cluster, running on Minikube. Includes a simple NestJS backend and NextJS frontend for integration testing, managed entirely via `kubectl` CLI scripts.

## Architecture Overview

```
Internet (localhost via port-forward)
        │
    ┌───▼───┐
    │ APISIX │  ← API Gateway (standalone mode with etcd)
    └───┬───┘
        │  reads routes from etcd
    ┌───▼───┐
    │  etcd  │  ← Configuration store (self-hosted StatefulSet)
    └───────┘
        │
   ┌────┴────┐
   │         │
┌──▼──┐  ┌──▼───┐
│ BE  │  │  FE  │  ← NestJS backend + NextJS frontend
└─────┘  └──────┘
```

APISIX routes:
- `/api/*` → Backend (NestJS on port 3001)
- `/*` → Frontend (NextJS on port 3000)

---

## Proposed Changes

### 1. NestJS Backend (`apps/backend`)

#### [NEW] [package.json](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/apps/backend/package.json)
Minimal NestJS app with a health check endpoint (`GET /api/health`) and a sample data endpoint (`GET /api/data`).

#### [NEW] [Dockerfile](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/apps/backend/Dockerfile)
Multi-stage Docker build for production NestJS image.

Key files: `src/main.ts`, `src/app.module.ts`, `src/app.controller.ts`, `src/app.service.ts`, `tsconfig.json`, `nest-cli.json`

---

### 2. NextJS Frontend (`apps/frontend`)

#### [NEW] [package.json](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/apps/frontend/package.json)
Minimal Next.js app that calls the backend API through APISIX and displays results.

#### [NEW] [Dockerfile](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/apps/frontend/Dockerfile)
Multi-stage Docker build for production NextJS image (standalone output).

Key files: `src/app/page.tsx`, `src/app/layout.tsx`, `next.config.js`

---

### 3. Kubernetes Manifests (`k8s/`)

#### [NEW] [namespace.yaml](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/k8s/namespace.yaml)
Creates `apisix-sandbox` namespace.

#### [NEW] [etcd.yaml](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/k8s/etcd.yaml)
- **StatefulSet** — single-node etcd v3.5 for simplicity
- **Service** — ClusterIP headless service for etcd discovery

#### [NEW] [apisix.yaml](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/k8s/apisix.yaml)
- **ConfigMap** — `config.yaml` pointing APISIX to the etcd service
- **Deployment** — APISIX 3.x with 1 replica
- **Service** — ClusterIP exposing port 9080 (proxy) and 9180 (Admin API)

#### [NEW] [apisix-routes.yaml](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/k8s/apisix-routes.yaml)
ConfigMap containing a shell script that uses the APISIX Admin API to create routes:
- Route 1: `/api/*` → upstream `backend-svc:3001`
- Route 2: `/*` → upstream `frontend-svc:3000`

#### [NEW] [backend.yaml](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/k8s/backend.yaml)
Deployment + Service for the NestJS backend (port 3001).

#### [NEW] [frontend.yaml](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/k8s/frontend.yaml)
Deployment + Service for the NextJS frontend (port 3000).

---

### 4. kubectl Scripts (`scripts/`)

#### [NEW] [setup.sh](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/scripts/setup.sh)
Start Minikube, enable addons, build Docker images inside Minikube, and deploy everything.

#### [NEW] [deploy.sh](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/scripts/deploy.sh)
Apply all K8s manifests in the correct order and configure APISIX routes.

#### [NEW] [build-images.sh](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/scripts/build-images.sh)
Build Docker images using Minikube's Docker daemon.

#### [NEW] [status.sh](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/scripts/status.sh)
Show pod, service, and endpoint status for the sandbox namespace.

#### [NEW] [logs.sh](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/scripts/logs.sh)
Tail logs for a specified component (etcd / apisix / backend / frontend).

#### [NEW] [port-forward.sh](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/scripts/port-forward.sh)
Port-forward APISIX gateway to `localhost:9080` for local testing.

#### [NEW] [configure-routes.sh](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/scripts/configure-routes.sh)
Configure APISIX routes via the Admin API using `curl`.

#### [NEW] [cleanup.sh](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/scripts/cleanup.sh)
Delete namespace and optionally stop Minikube.

---

### 5. Project Root

#### [NEW] [README.md](file:///Users/tuanlv/Desktop/learn-space/k8s/apisix-standalone-etcd-self-host/README.md)
Complete guide: prerequisites, quickstart, architecture, scripts reference, and troubleshooting.

---

## Verification Plan

### Manual Verification (via user testing on Minikube)

1. **Start Minikube** — `./scripts/setup.sh`
2. **Check pods** — `./scripts/status.sh` → all pods should be `Running`
3. **Port-forward** — `./scripts/port-forward.sh`
4. **Test backend through APISIX** — `curl http://localhost:9080/api/health` → `{"status":"ok"}`
5. **Test frontend through APISIX** — open `http://localhost:9080/` in browser → NextJS page loads
6. **View logs** — `./scripts/logs.sh apisix` → see request logs
7. **Cleanup** — `./scripts/cleanup.sh`
