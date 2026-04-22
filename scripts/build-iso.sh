#!/bin/bash
# build-iso.sh — host-side wrapper around `make iso-<arch>`
# Convenience: runs prep + lb config + lb build for the chosen arch.
set -euo pipefail

ARCH="${1:-amd64}"

case "$ARCH" in
    amd64|arm64) ;;
    *) echo "Usage: $0 [amd64|arm64]"; exit 1 ;;
esac

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

make "iso-${ARCH}"
