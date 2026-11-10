# Note File Mode

Read a note from a regular file with `note.sh --file PATH`.
The file is printed verbatim: empty files, embedded newlines,
and final newlines are preserved byte for byte.

```sh
printf 'line one\nline two\n' > memo.txt
bash note.sh --file memo.txt
# output: line one, line two (each on its own line, final newline kept)
```

```sh
: > empty.txt
bash note.sh --file empty.txt
# output: (empty)
```

```sh
printf 'no trailing newline' > exact.txt
bash note.sh --file exact.txt
# output: no trailing newline (no newline added)
```

Paths containing spaces work when quoted:

```sh
bash note.sh --file "my note file.txt"
```

Missing files, directories, and unreadable files fail with an
error message on stderr and a nonzero status.

## Literal versus file arguments

- One argument is always a literal note, printed unchanged:
  `bash note.sh 'Walk the dog'`, `bash note.sh ''`, and even
  `bash note.sh --file` print exactly the string given.
- Two arguments are accepted only as `--file PATH`, which reads
  the regular file at PATH verbatim.
- Any other argument count (zero, three or more) or any other
  two-argument form (for example `bash note.sh foo bar`) fails
  with usage guidance on stderr and a nonzero status.
