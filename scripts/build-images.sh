#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APPS_DIR="$(dirname "$SCRIPT_DIR")/apps"

# ─── Colors & Symbols ────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

TICK="${GREEN}✔${NC}"
ARROW="${CYAN}▶${NC}"

section() {
  echo ""
  echo -e "  ${DIM}──────────${NC} ${BOLD}${YELLOW}$1${NC} ${DIM}──────────${NC}"
  echo ""
}

step()    { echo -e "  ${ARROW}  $1"; }
success() { echo -e "  ${TICK}  ${GREEN}$1${NC}"; }
info()    { echo -e "  ${DIM}   $1${NC}"; }

# ─── Main ─────────────────────────────────────────────────────────────
section "BUILD DOCKER IMAGES"

step "Pointing Docker CLI to Minikube daemon..."
eval $(minikube docker-env)
success "Docker context switched"

SERVICES=(product-service order-service storefront admin)

for svc in "${SERVICES[@]}"; do
  echo ""
  step "Building ${BOLD}${svc}${NC} image..."
  info "sandbox-${svc}:latest  ←  ${APPS_DIR}/${svc}"
  docker build -t "sandbox-${svc}:latest" "$APPS_DIR/$svc"
  success "${svc} image built"
done

echo ""
echo -e "  ${DIM}┌──────────────────────────────────────────────────┐${NC}"
echo -e "  ${DIM}│${NC}  ${BOLD}Built Images:${NC}                                    ${DIM}│${NC}"
docker images | grep sandbox | while IFS= read -r line; do
  echo -e "  ${DIM}│${NC}    ${DIM}${line}${NC}"
done
echo -e "  ${DIM}└──────────────────────────────────────────────────┘${NC}"
echo ""
