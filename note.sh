#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 '<note>'" >&2
  exit 1
fi
printf '%s' "$1"
