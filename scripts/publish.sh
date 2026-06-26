#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/sebastien/ABLS-RPMS"
ARCHES=("x86_64" "aarch64" "noarch")
CLEAN_MODE=0

if [[ "${1:-}" == "clean" || "${1:-}" == "--clean" ]]; then
  CLEAN_MODE=1
elif [[ -n "${1:-}" ]]; then
  echo "ERROR: unknown argument: $1" >&2
  echo "Usage: $0 [clean|--clean]" >&2
  exit 1
fi

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: missing command: $cmd" >&2
    exit 1
  fi
}

require_cmd rsync

if command -v createrepo_c >/dev/null 2>&1; then
  CREATEREPO_CMD="createrepo_c"
elif command -v createrepo >/dev/null 2>&1; then
  CREATEREPO_CMD="createrepo"
else
  echo "ERROR: missing command: createrepo_c or createrepo" >&2
  exit 1
fi

mkdir -p "$BASE_DIR/published/repo" "$BASE_DIR/published/keys"

for arch in "${ARCHES[@]}"; do
  src="$BASE_DIR/repo/$arch"
  dst="$BASE_DIR/published/repo/$arch"

  mkdir -p "$src" "$dst"

  if [[ "$CLEAN_MODE" -eq 1 ]]; then
    find "$dst" -maxdepth 1 -type f -name "*.rpm" -delete
    find "$dst" -maxdepth 1 -type f -name "*.src.rpm" -delete
  fi

  rsync -a "$src/" "$dst/"

  # Keep metadata aligned with what is effectively published.
  "$CREATEREPO_CMD" --update "$dst" >/dev/null
done

if [[ -f "$BASE_DIR/keys/RPM-GPG-KEY-ABLS" ]]; then
  cp -f "$BASE_DIR/keys/RPM-GPG-KEY-ABLS" "$BASE_DIR/published/keys/"
fi
if [[ -f "$BASE_DIR/keys/RPM-GPG-KEY-ABLS.sha256" ]]; then
  cp -f "$BASE_DIR/keys/RPM-GPG-KEY-ABLS.sha256" "$BASE_DIR/published/keys/"
fi
if [[ -f "$BASE_DIR/abls-rpms.repo" ]]; then
  cp -f "$BASE_DIR/abls-rpms.repo" "$BASE_DIR/published/"
fi

if [[ "$CLEAN_MODE" -eq 1 ]]; then
  echo "OK: published repository updated in-place in $BASE_DIR/published (clean mode)"
else
  echo "OK: published repository updated in-place in $BASE_DIR/published (incremental mode)"
fi
