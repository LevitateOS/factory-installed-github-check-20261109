#!/usr/bin/env bash
# Standalone checks for note.sh literal and --file modes.
# Uses only bash and coreutils; no network or extra dependencies.
set -euo pipefail

cd "$(dirname "$0")"

TMPD="$(mktemp -d)"
trap 'rm -rf "$TMPD"' EXIT

pass=0
fail_one() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

# --- literal mode: exact stdout preserved ---
[ "$(bash note.sh 'Walk the dog')" = 'Walk the dog' ] || fail_one 'literal basic'
[ "$(bash note.sh '')" = '' ] || fail_one 'literal empty'
[ "$(bash note.sh '--file')" = '--file' ] || fail_one 'literal --file'
[ "$(bash note.sh '-n hello')" = '-n hello' ] || fail_one 'literal dash-n'
pass=$((pass+4))

# --- file mode: byte-exact output via cmp ---
: > "$TMPD/empty.txt"
bash note.sh --file "$TMPD/empty.txt" > "$TMPD/got-empty.bin"
[ ! -s "$TMPD/got-empty.bin" ] || fail_one 'file empty'
pass=$((pass+1))

printf 'line one\nline two\n' > "$TMPD/multi.txt"
bash note.sh --file "$TMPD/multi.txt" > "$TMPD/got-multi.bin"
cmp -s "$TMPD/multi.txt" "$TMPD/got-multi.bin" || fail_one 'file multiline final newline'
pass=$((pass+1))

printf 'no trailing newline' > "$TMPD/notrail.txt"
bash note.sh --file "$TMPD/notrail.txt" > "$TMPD/got-notrail.bin"
cmp -s "$TMPD/notrail.txt" "$TMPD/got-notrail.bin" || fail_one 'file no trailing newline'
pass=$((pass+1))

printf 'spaced path works\n' > "$TMPD/my note file.txt"
bash note.sh --file "$TMPD/my note file.txt" > "$TMPD/got-spaced.bin"
cmp -s "$TMPD/my note file.txt" "$TMPD/got-spaced.bin" || fail_one 'file spaced path'
pass=$((pass+1))

# --- failure cases: usage guidance ---
if out=$(bash note.sh 2>&1); then fail_one 'zero args must fail'; fi
case "$out" in *[Uu]sage:*) ;; *) fail_one 'zero args usage';; esac
pass=$((pass+1))

if out=$(bash note.sh a b c 2>&1); then fail_one 'three args must fail'; fi
case "$out" in *[Uu]sage:*) ;; *) fail_one 'three args usage';; esac
pass=$((pass+1))

if out=$(bash note.sh foo bar 2>&1); then fail_one 'other two-arg form must fail'; fi
case "$out" in *[Uu]sage:*) ;; *) fail_one 'other two-arg usage';; esac
pass=$((pass+1))

if out=$(bash note.sh --file extra1 extra2 2>&1); then fail_one 'three args with --file must fail'; fi
case "$out" in *[Uu]sage:*) ;; *) fail_one 'three args with --file usage';; esac
pass=$((pass+1))

# --- failure cases: file errors report on stderr with nonzero status ---
if err=$(bash note.sh --file "$TMPD/does-not-exist.txt" 2>&1); then fail_one 'missing file must fail'; fi
[ -n "$err" ] || fail_one 'missing file stderr'
pass=$((pass+1))

mkdir -p "$TMPD/somedir"
if err=$(bash note.sh --file "$TMPD/somedir" 2>&1); then fail_one 'directory must fail'; fi
[ -n "$err" ] || fail_one 'directory stderr'
pass=$((pass+1))

printf 'secret\n' > "$TMPD/noperm.txt"
chmod 000 "$TMPD/noperm.txt"
if [ -r "$TMPD/noperm.txt" ]; then
  printf 'SKIP: unreadable test (running with privilege)\n'
else
  if err=$(bash note.sh --file "$TMPD/noperm.txt" 2>&1); then fail_one 'unreadable file must fail'; fi
  [ -n "$err" ] || fail_one 'unreadable stderr'
  pass=$((pass+1))
fi
chmod 644 "$TMPD/noperm.txt" || true

printf 'All %s checks passed.\n' "$pass"
