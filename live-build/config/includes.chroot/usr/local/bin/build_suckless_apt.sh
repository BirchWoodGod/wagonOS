#!/bin/bash
# build_suckless_apt.sh — apt-based build of wagonOS suckless components.
#
# This is the MINIMAL first version. The full apt port of
# suckless-source/build_suckless.sh (interactive menus, color/modkey
# selection, ly animation choice, network interface detection) will land
# in a follow-up.
#
# Usage:
#   build_suckless_apt.sh                  # interactive (when TTY)
#   build_suckless_apt.sh --non-interactive  # non-interactive (used by chroot hook)
#   SL_DIR=/path/to/sl build_suckless_apt.sh

set -euo pipefail

SL_DIR="${SL_DIR:-/usr/share/wagonos/sl}"
COMPONENTS=("dwm" "dmenu" "st" "slstatus")
NON_INTERACTIVE=0

for arg in "$@"; do
    case "$arg" in
        --non-interactive|-y) NON_INTERACTIVE=1 ;;
        --help|-h)
            sed -n '2,12p' "$0"
            exit 0
            ;;
    esac
done

if [[ ! -d "$SL_DIR" ]]; then
    echo "ERROR: suckless source directory not found: $SL_DIR" >&2
    exit 1
fi

SUDO=""
if [[ $EUID -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        echo "ERROR: must run as root (or with sudo available)" >&2
        exit 1
    fi
fi

for c in "${COMPONENTS[@]}"; do
    if [[ ! -d "$SL_DIR/$c" ]]; then
        echo "[wagonOS] Skipping $c (not found in $SL_DIR)"
        continue
    fi
    echo "[wagonOS] Building $c..."
    cd "$SL_DIR/$c"
    $SUDO make clean
    $SUDO make install
done

echo "[wagonOS] Suckless components built and installed."
