#!/usr/bin/env bash
set -euo pipefail

COMPONENT="${1:-}"

# ─── Colors & Symbols ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

ARROW="${CYAN}▶${NC}"

# ─── Validate input ──────────────────────────────────────────────────
case "$COMPONENT" in
  etcd|apisix)
    NS="common"
    COLOR="${BLUE}"
    ;;
  backend|frontend)
    NS="app"
    COLOR="${GREEN}"
    ;;
  *)
    echo ""
    echo -e "  ${CYAN}${BOLD}╔════════════════════════════════════════════════╗${NC}"
    echo -e "  ${CYAN}${BOLD}║${NC}  ${BOLD}📋  APISIX Sandbox Log Viewer${NC}                  ${CYAN}${BOLD}║${NC}"
    echo -e "  ${CYAN}${BOLD}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${YELLOW}Usage:${NC}  $0 ${DIM}<component>${NC}"
    echo ""
    echo -e "  ${DIM}┌────────────────────────────────────────────┐${NC}"
    echo -e "  ${DIM}│${NC}  ${BOLD}Component${NC}     ${BOLD}Namespace${NC}                    ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  ${DIM}─────────     ─────────${NC}                    ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  ${BLUE}etcd${NC}          common                       ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  ${BLUE}apisix${NC}        common                       ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  ${GREEN}backend${NC}       app                          ${DIM}│${NC}"
    echo -e "  ${DIM}│${NC}  ${GREEN}frontend${NC}      app                          ${DIM}│${NC}"
    echo -e "  ${DIM}└────────────────────────────────────────────┘${NC}"
    echo ""
    exit 1
    ;;
esac

# ─── Tail logs ────────────────────────────────────────────────────────
echo ""
echo -e "  ${ARROW}  Tailing logs: ${COLOR}${BOLD}${COMPONENT}${NC}  ${DIM}(namespace: ${NS})${NC}"
echo -e "  ${DIM}────────────────────────────────────────────────${NC}"
echo ""

kubectl logs -f -l "app=$COMPONENT" -n "$NS" --tail=100
