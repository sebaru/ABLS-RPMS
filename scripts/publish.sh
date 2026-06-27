#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
PUBLIC_DIR="$BASE_DIR/public"
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

if command -v createrepo_c >/dev/null 2>&1; then
  CREATEREPO_CMD="createrepo_c"
elif command -v createrepo >/dev/null 2>&1; then
  CREATEREPO_CMD="createrepo"
else
  echo "ERROR: missing command: createrepo_c or createrepo" >&2
  exit 1
fi

mkdir -p "$PUBLIC_DIR" "$PUBLIC_DIR/keys"

for arch in "${ARCHES[@]}"; do
  dst="$PUBLIC_DIR/$arch"
  mkdir -p "$dst"

  if [[ "$CLEAN_MODE" -eq 1 ]]; then
    find "$dst" -maxdepth 1 -type f -name "*.rpm" -delete
    find "$dst" -maxdepth 1 -type f -name "*.src.rpm" -delete
  fi

  # Keep metadata aligned with what is effectively exposed.
  "$CREATEREPO_CMD" --update "$dst" >/dev/null
done

if [[ -f "$PUBLIC_DIR/keys/RPM-GPG-KEY-ABLS" ]]; then
  sha256sum "$PUBLIC_DIR/keys/RPM-GPG-KEY-ABLS" | awk '{print $1 "  keys/RPM-GPG-KEY-ABLS"}' > "$PUBLIC_DIR/keys/RPM-GPG-KEY-ABLS.sha256"
fi

if [[ ! -f "$PUBLIC_DIR/abls-rpms.repo" ]]; then
  cat > "$PUBLIC_DIR/abls-rpms.repo" <<'EOF'
[abls-rpms]
name=ABLS RPM Repository
baseurl=https://rpms.abls-habitat.fr/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://rpms.abls-habitat.fr/keys/RPM-GPG-KEY-ABLS
EOF
fi

if [[ "$CLEAN_MODE" -eq 1 ]]; then
  echo "OK: repository updated in-place in public/ (clean mode)"
else
  echo "OK: repository updated in-place in public/ (incremental mode)"
fi
