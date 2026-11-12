#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -ge 1 ] && [ "$1" = "--uppercase" ]; then
  if [ "$#" -ne 2 ]; then
    echo "Usage: $0 --uppercase '<note>'" >&2
    exit 1
  fi
  printf '%s\n' "$2" | LC_ALL=C tr '[:lower:]' '[:upper:]'
  exit 0
fi
if [ "$#" -eq 1 ] && [ "$1" = "--version" ]; then
  echo "note.sh 1.0.0"
  exit 0
fi
if [ "$#" -eq 1 ] && [ "$1" = "--help" ]; then
  echo "Usage: $0 '<note>'"
  echo "Usage: $0 --file PATH"
  echo "Usage: $0 --version"
  echo "Usage: $0 --uppercase '<note>'"
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
  echo "Usage: $0 --version" >&2
  echo "Usage: $0 --uppercase '<note>'" >&2
  exit 1
fi
printf '%s' "$1"
