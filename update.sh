#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/scripts"

if [[ -n "${1:-}" ]]; then
	echo "ERROR: unknown argument: $1" >&2
	echo "Usage: $0" >&2
	exit 1
fi

"$SCRIPT_DIR/update-rpm.sh"
"$SCRIPT_DIR/update-deb.sh"
"$SCRIPT_DIR/verify-repo.sh"
git add public/

echo "OK: update completed (publish rpm/deb + verify rpm)"
