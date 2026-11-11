#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -eq 1 ] && [ "$1" = "--help" ]; then
  echo "Usage: $0 '<note>'"
  echo "Usage: $0 --file PATH"
  echo "Usage: $0 --license"
  exit 0
fi
if [ "$#" -eq 1 ] && [ "$1" = "--license" ]; then
  echo "MIT"
  exit 0
fi
if [ "$#" -eq 2 ]; then
  if [ "$1" = "--file" ]; then
    path="$2"
    if [ ! -e "$path" ]; then
      echo "Error: file not found" >&2
      exit 1
    fi
    if [ ! -f "$path" ]; then
      echo "Error: not a regular file" >&2
      exit 1
    fi
    if [ ! -r "$path" ]; then
      echo "Error: file is not readable" >&2
      exit 1
    fi
    cat -- "$path"
    exit 0
  fi
fi
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 '<note>'" >&2
  echo "Usage: $0 --file PATH" >&2
  exit 1
fi
printf '%s' "$1"
