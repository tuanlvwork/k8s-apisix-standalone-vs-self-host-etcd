#!/usr/bin/env bash
set -euo pipefail

# ─── Colors & Symbols ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

TICK="${GREEN}✔${NC}"
CROSS="${RED}✘${NC}"
ARROW="${CYAN}▶${NC}"

section() {
  echo ""
  echo -e "  ${DIM}──────────${NC} ${BOLD}${YELLOW}$1${NC} ${DIM}──────────${NC}"
  echo ""
}

step()    { echo -e "  ${ARROW}  $1"; }
success() { echo -e "  ${TICK}  ${GREEN}$1${NC}"; }
warn()    { echo -e "  ${CROSS}  ${RED}$1${NC}"; }

# ─── Main ─────────────────────────────────────────────────────────────
echo ""
echo -e "  ${CYAN}${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "  ${CYAN}${BOLD}║${NC}  ${BOLD}🧹  APISIX Sandbox Cleanup${NC}                  ${CYAN}${BOLD}║${NC}"
echo -e "  ${CYAN}${BOLD}╚══════════════════════════════════════════════╝${NC}"

section "NAMESPACES"

step "Deleting namespace ${BOLD}common${NC}..."
kubectl delete namespace common --ignore-not-found 2>/dev/null && \
  success "common namespace deleted" || warn "common namespace not found"

step "Deleting namespace ${BOLD}app${NC}..."
kubectl delete namespace app --ignore-not-found 2>/dev/null && \
  success "app namespace deleted" || warn "app namespace not found"

if [ "${1:-}" = "--stop-minikube" ]; then
  section "MINIKUBE"
  step "Stopping Minikube cluster..."
  minikube stop
  success "Minikube stopped"
fi

echo ""
echo -e "  ${DIM}────────────────────────────────────────────────${NC}"
echo -e "  ${TICK}  ${GREEN}${BOLD}Cleanup complete${NC}"
echo -e "  ${DIM}────────────────────────────────────────────────${NC}"
echo ""
