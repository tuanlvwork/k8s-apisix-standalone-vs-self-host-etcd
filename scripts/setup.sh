#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# ─── Colors & Symbols ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

TICK="${GREEN}✔${NC}"
CROSS="${RED}✘${NC}"
ARROW="${CYAN}▶${NC}"
GEAR="${YELLOW}⚙${NC}"
ROCKET="${MAGENTA}🚀${NC}"

# ─── UI Helpers ───────────────────────────────────────────────────────
banner() {
  echo ""
  echo -e "${CYAN}${BOLD}"
  echo "  ╔══════════════════════════════════════════════════════╗"
  echo "  ║                                                      ║"
  echo "  ║        █████╗ ██████╗ ██╗███████╗██╗██╗  ██╗         ║"
  echo "  ║       ██╔══██╗██╔══██╗██║██╔════╝██║╚██╗██╔╝         ║"
  echo "  ║       ███████║██████╔╝██║███████╗██║ ╚███╔╝          ║"
  echo "  ║       ██╔══██║██╔═══╝ ██║╚════██║██║ ██╔██╗          ║"
  echo "  ║       ██║  ██║██║     ██║███████║██║██╔╝ ██╗         ║"
  echo "  ║       ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝╚═╝  ╚═╝         ║"
  echo "  ║                                                      ║"
  echo "  ║          S A N D B O X    S E T U P                  ║"
  echo "  ║          etcd  ·  APISIX  ·  Apps                    ║"
  echo "  ║                                                      ║"
  echo "  ╚══════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

section() {
  local title="$1"
  local width=54
  local pad=$(( (width - ${#title} - 2) / 2 ))
  local lpad=$(printf '%*s' "$pad" '' | tr ' ' '─')
  local rpad=$(printf '%*s' "$pad" '' | tr ' ' '─')
  echo ""
  echo -e "  ${DIM}${lpad}${NC} ${BOLD}${YELLOW}${title}${NC} ${DIM}${rpad}${NC}"
  echo ""
}

step() {
  echo -e "  ${ARROW}  $1"
}

success() {
  echo -e "  ${TICK}  ${GREEN}$1${NC}"
}

fail() {
  echo -e "  ${CROSS}  ${RED}$1${NC}"
}

info() {
  echo -e "  ${DIM}   $1${NC}"
}

# ─── Main ─────────────────────────────────────────────────────────────
banner

# 1. Minikube
section "MINIKUBE"
if ! minikube status | grep -q "Running"; then
  step "Starting Minikube cluster..."
  info "cpus=4  memory=4096  driver=docker"
  minikube start --cpus=4 --memory=4096 --driver=docker
  success "Minikube started"
else
  success "Minikube is already running"
fi

# 2. Docker images
section "DOCKER IMAGES"
step "Building images inside Minikube..."
"$SCRIPT_DIR/build-images.sh"

# 3. K8s manifests
section "KUBERNETES DEPLOY"
step "Deleting stale route-init job (if any)..."
# The Job must be deleted before apply so it re-runs with fresh route config.
# kubectl apply on an existing completed Job has no effect — routes would never re-seed.
kubectl delete job/apisix-route-init -n common --ignore-not-found 1>/dev/null && \
  info "Stale job removed (will be re-created by deploy)" || true
step "Applying Kustomize manifests..."
"$SCRIPT_DIR/deploy.sh"

# 4. Wait for pods
section "WAITING FOR PODS"
step "etcd  →  common namespace"
kubectl wait --for=condition=ready pod -l app=etcd -n common --timeout=120s 2>/dev/null && \
  success "etcd is ready" || fail "etcd timeout"

step "apisix  →  common namespace"
kubectl wait --for=condition=ready pod -l app=apisix -n common --timeout=120s 2>/dev/null && \
  success "apisix is ready" || fail "apisix timeout"

for svc in product-service order-service storefront admin; do
  step "${svc}  →  app namespace"
  kubectl wait --for=condition=ready pod -l "app=${svc}" -n app --timeout=120s 2>/dev/null && \
    success "${svc} is ready" || fail "${svc} timeout"
done

# 5. Route init job
section "APISIX ROUTES"
step "Waiting for route-init job to complete..."
kubectl wait --for=condition=complete job/apisix-route-init -n common --timeout=120s 2>/dev/null && \
  success "Routes configured" || fail "Route init timeout"

# 6. Status
section "CLUSTER STATUS"
"$SCRIPT_DIR/status.sh"

# Done
echo ""
echo -e "  ${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "  ${CYAN}${BOLD}║${NC}  ${ROCKET}  ${GREEN}${BOLD}Setup complete!${NC}                                  ${CYAN}${BOLD}║${NC}"
echo -e "  ${CYAN}${BOLD}║${NC}                                                      ${CYAN}${BOLD}║${NC}"
echo -e "  ${CYAN}${BOLD}║${NC}  ${DIM}Next steps:${NC}                                          ${CYAN}${BOLD}║${NC}"
echo -e "  ${CYAN}${BOLD}║${NC}    ${ARROW}  ${BOLD}./scripts/port-forward.sh${NC}                      ${CYAN}${BOLD}║${NC}"
echo -e "  ${CYAN}${BOLD}║${NC}    ${DIM}Storefront:${NC} ${BLUE}http://localhost:9080/services/storefront/${NC}         ${CYAN}${BOLD}║${NC}"
echo -e "  ${CYAN}${BOLD}║${NC}    ${DIM}Admin:     ${NC} ${BLUE}http://localhost:9080/services/admin/${NC}              ${CYAN}${BOLD}║${NC}"
echo -e "  ${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
