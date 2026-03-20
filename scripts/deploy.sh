#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
K8S_DIR="$(dirname "$SCRIPT_DIR")/k8s"
OVERLAY="${1:-dev}"

# ─── Colors & Symbols ────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
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
section "DEPLOY K8S MANIFESTS"

step "Applying Kustomize overlay: ${BOLD}${BLUE}${OVERLAY}${NC}"
info "Path: ${K8S_DIR}/overlays/${OVERLAY}"
echo ""

kubectl apply -k "$K8S_DIR/overlays/$OVERLAY"

echo ""
success "All manifests applied"
echo ""
echo -e "  ${DIM}┌────────────────────────────────────────────┐${NC}"
echo -e "  ${DIM}│${NC}  ${BOLD}Overlay:${NC}  ${BLUE}${OVERLAY}${NC}                              ${DIM}│${NC}"
echo -e "  ${DIM}│${NC}                                            ${DIM}│${NC}"
echo -e "  ${DIM}│${NC}  ${DIM}common${NC}  →  etcd, apisix                  ${DIM}│${NC}"
echo -e "  ${DIM}│${NC}  ${DIM}app${NC}     →  backend, frontend              ${DIM}│${NC}"
echo -e "  ${DIM}└────────────────────────────────────────────┘${NC}"
echo ""
