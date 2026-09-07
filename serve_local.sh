#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if [ "${1:-}" = "--render" ]; then
  quarto render
  python3 -m http.server 4000 --directory _site
else
  quarto preview --port 4000
fi
