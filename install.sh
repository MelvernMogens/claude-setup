#!/usr/bin/env bash
# Restore this Claude Code setup onto a machine. Safe to re-run.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.claude"

mkdir -p "$DEST/skills"

# Never clobber a local CLAUDE.md without keeping a copy.
if [ -e "$DEST/CLAUDE.md" ] && ! diff -q "$SRC/CLAUDE.md" "$DEST/CLAUDE.md" >/dev/null 2>&1; then
  cp "$DEST/CLAUDE.md" "$DEST/CLAUDE.md.before-install"
  echo "kept a copy of the existing one -> CLAUDE.md.before-install"
fi
cp "$SRC/CLAUDE.md" "$DEST/CLAUDE.md"
echo "installed: CLAUDE.md"

for d in "$SRC"/skills/*/; do
  name="$(basename "$d")"
  [ -d "$DEST/skills/$name" ] && rm -r "$DEST/skills/$name"
  cp -R "$d" "$DEST/skills/$name"
  echo "installed: skills/$name"
done

echo
echo "Done. Restart Claude Code — skills only load at session start."
