#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/bootstrap-repo.sh"
"$SCRIPT_DIR/sync-rpms.sh"
"$SCRIPT_DIR/publish.sh"
"$SCRIPT_DIR/verify-repo.sh"

echo "OK: update completed (collect + metadata + publish + verify)"
