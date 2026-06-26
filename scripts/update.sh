#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CLEAN_MODE=0

if [[ "${1:-}" == "clean" || "${1:-}" == "--clean" ]]; then
	CLEAN_MODE=1
elif [[ -n "${1:-}" ]]; then
	echo "ERROR: unknown argument: $1" >&2
	echo "Usage: $0 [clean|--clean]" >&2
	exit 1
fi

"$SCRIPT_DIR/bootstrap-repo.sh"
if [[ "$CLEAN_MODE" -eq 1 ]]; then
	"$SCRIPT_DIR/sync-rpms.sh" --clean
	"$SCRIPT_DIR/publish.sh" --clean
else
	"$SCRIPT_DIR/sync-rpms.sh"
	"$SCRIPT_DIR/publish.sh"
fi
"$SCRIPT_DIR/verify-repo.sh"

if [[ "$CLEAN_MODE" -eq 1 ]]; then
	echo "OK: update completed (clean collect + metadata + publish + verify)"
else
	echo "OK: update completed (incremental collect + metadata + publish + verify)"
fi
