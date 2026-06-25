#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/sebastien/ABLS-RPMS"
SOURCE_DIRS=(
  "/home/sebastien/ABLS-LIBS/build"
  "/home/sebastien/ABLS-SATELLITE-LIBS/build"
)
ARCHES=("x86_64" "aarch64" "noarch")

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: missing command: $cmd" >&2
    exit 1
  fi
}

require_cmd find
require_cmd rpm
require_cmd cp

for arch in "${ARCHES[@]}"; do
  mkdir -p "$BASE_DIR/repo/$arch"
  find "$BASE_DIR/repo/$arch" -maxdepth 1 -type f -name "*.rpm" -delete
  find "$BASE_DIR/repo/$arch" -maxdepth 1 -type f -name "*.src.rpm" -delete
done

copied=0

for src in "${SOURCE_DIRS[@]}"; do
  if [[ ! -d "$src" ]]; then
    echo "WARN: source directory not found: $src" >&2
    continue
  fi

  while IFS= read -r -d '' rpm_file; do
    arch="$(rpm -qp --qf '%{ARCH}' "$rpm_file" 2>/dev/null || true)"
    case "$arch" in
      x86_64|aarch64|noarch)
        cp -f "$rpm_file" "$BASE_DIR/repo/$arch/"
        copied=$((copied + 1))
        ;;
      *)
        echo "WARN: unsupported or unreadable arch for $rpm_file (arch=$arch)" >&2
        ;;
    esac
  done < <(find "$src" -maxdepth 1 -type f -name "*.rpm" -print0)
done

echo "OK: synchronized $copied RPM files from ABLS-LIBS and ABLS-SATELLITE-LIBS"
