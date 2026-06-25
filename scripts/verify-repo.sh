#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/sebastien/ABLS-RPMS"
ARCHES=("x86_64" "aarch64" "noarch")
KEY_FILE="$BASE_DIR/keys/RPM-GPG-KEY-ABLS"
KEY_SUM="$BASE_DIR/keys/RPM-GPG-KEY-ABLS.sha256"
PUBLISHED_REPO_FILE="$BASE_DIR/published/abls-rpms.repo"

fail() {
  echo "ERROR: $1" >&2
  exit 1
}

[[ -f "$KEY_FILE" ]] || fail "missing key file: $KEY_FILE"
[[ -f "$KEY_SUM" ]] || fail "missing key checksum: $KEY_SUM"

expected_sum="$(awk '{print $1}' "$KEY_SUM" | head -n 1)"
actual_sum="$(sha256sum "$KEY_FILE" | awk '{print $1}')"
[[ -n "$expected_sum" ]] || fail "empty checksum in $KEY_SUM"
[[ "$expected_sum" == "$actual_sum" ]] || fail "checksum mismatch for $KEY_FILE"

gpg --show-keys --fingerprint "$KEY_FILE" >/dev/null

for arch in "${ARCHES[@]}"; do
  dir="$BASE_DIR/published/repo/$arch"
  [[ -d "$dir" ]] || continue

  rpm_count="$(find "$dir" -maxdepth 1 -type f -name '*.rpm' | wc -l)"
  if [[ "$rpm_count" -gt 0 ]]; then
    [[ -f "$dir/repodata/repomd.xml" ]] || fail "missing repodata for $arch"
  fi
done

if command -v dnf >/dev/null 2>&1 && [[ -f "$PUBLISHED_REPO_FILE" ]]; then
  dnf -q --disablerepo='*' --repofrompath='abls-rpms,file:///home/sebastien/ABLS-RPMS/published/repo/x86_64' --enablerepo='abls-rpms' makecache >/dev/null || true
fi

echo "OK: repository checks completed"
