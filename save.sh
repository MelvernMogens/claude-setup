#!/usr/bin/env bash
# Copy the live setup in ~/.claude back into this repo.
# Run this after changing a skill, then review the diff before committing.
set -euo pipefail

DEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$HOME/.claude"

cp "$SRC/CLAUDE.md" "$DEST/CLAUDE.md"

# Update the skills this repo already tracks.
for name in $(ls "$DEST/skills"); do
  if [ ! -d "$SRC/skills/$name" ]; then
    echo "skipped — no longer in ~/.claude: $name"
    continue
  fi
  rm -r "$DEST/skills/$name"
  cp -R "$SRC/skills/$name" "$DEST/skills/$name"
  echo "saved: skills/$name"
done

# Point out anything new that this repo is not tracking yet.
for d in "$SRC"/skills/*/; do
  name="$(basename "$d")"
  [ -d "$DEST/skills/$name" ] || echo "NOT TRACKED (copy it in by hand if you want it): $name"
done

echo
echo "review with:  git -C \"$DEST\" diff"
