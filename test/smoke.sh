#!/bin/sh
# Placeholder so `make test` works on day one.
# Replace with your real host-side test runner (e.g. `pio test -e native`).
set -e
[ -f CLAUDE.md ] || { echo "FAIL: CLAUDE.md missing"; exit 1; }
[ -d intent ] || { echo "FAIL: intent/ missing"; exit 1; }
echo "All tests passed"
