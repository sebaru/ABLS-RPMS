#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/sebastien/ABLS-RPMS"
ARCHES=("x86_64" "aarch64" "noarch")
STAGING_DIR="$(mktemp -d "$BASE_DIR/.staging.XXXXXX")"
PREV_DIR="$BASE_DIR/.published.prev"

cleanup() {
  if [[ -d "$STAGING_DIR" ]]; then
    rm -rf "$STAGING_DIR"
  fi
}
trap cleanup EXIT

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

mkdir -p "$STAGING_DIR/repo" "$STAGING_DIR/keys"

for arch in "${ARCHES[@]}"; do
  src="$BASE_DIR/repo/$arch"
  dst="$STAGING_DIR/repo/$arch"

  mkdir -p "$src" "$dst"

  # Keep metadata aligned with current package pool for each architecture.
  "$CREATEREPO_CMD" --update "$src" >/dev/null
  rsync -a --delete "$src/" "$dst/"
done

if [[ -f "$BASE_DIR/keys/RPM-GPG-KEY-ABLS" ]]; then
  cp -f "$BASE_DIR/keys/RPM-GPG-KEY-ABLS" "$STAGING_DIR/keys/"
fi
if [[ -f "$BASE_DIR/keys/RPM-GPG-KEY-ABLS.sha256" ]]; then
  cp -f "$BASE_DIR/keys/RPM-GPG-KEY-ABLS.sha256" "$STAGING_DIR/keys/"
fi
if [[ -f "$BASE_DIR/abls-rpms.repo" ]]; then
  cp -f "$BASE_DIR/abls-rpms.repo" "$STAGING_DIR/"
fi

if [[ -d "$PREV_DIR" ]]; then
  rm -rf "$PREV_DIR"
fi

if [[ -d "$BASE_DIR/published" ]]; then
  mv "$BASE_DIR/published" "$PREV_DIR"
fi

mv "$STAGING_DIR" "$BASE_DIR/published"
STAGING_DIR=""

if [[ -d "$PREV_DIR" ]]; then
  rm -rf "$PREV_DIR"
fi

echo "OK: published repository snapshot updated in $BASE_DIR/published"
