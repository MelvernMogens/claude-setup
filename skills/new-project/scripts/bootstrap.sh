#!/usr/bin/env bash
# Scaffold a project with the standard Claude Code setup.
# Idempotent: never overwrites an existing file, reports what it skipped.
set -euo pipefail

TARGET="${1:-$PWD}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TPL="$ROOT/templates"

[ -d "$TPL" ] || { echo "error: templates not found at $TPL" >&2; exit 1; }
mkdir -p "$TARGET"; cd "$TARGET"

NAME="$(basename "$TARGET")"
created=(); skipped=()

place() {
  if [ -e "$2" ]; then skipped+=("$2"); else
    mkdir -p "$(dirname "$2")"; cp "$1" "$2"; created+=("$2")
  fi
}

if [ -d .git ]; then echo "git      : already a repo"; else git init -q && echo "git      : initialized"; fi

place "$TPL/gitignore"             ".gitignore"
place "$TPL/settings.json"         ".claude/settings.json"
place "$TPL/skills/check/SKILL.md" ".claude/skills/check/SKILL.md"
place "$TPL/skills/hard/SKILL.md"  ".claude/skills/hard/SKILL.md"

for pair in "CLAUDE.md:CLAUDE.md" "prd.md:docs/prd.md" "README.md:README.md" "security.md:docs/security.md" "ci.yml:.github/workflows/ci.yml"; do
  src="${pair%%:*}"; dst="${pair##*:}"
  if [ -e "$dst" ]; then skipped+=("$dst"); else
    mkdir -p "$(dirname "$dst")"
    sed "s/{{PROJECT_NAME}}/$NAME/g" "$TPL/$src" > "$dst"
    created+=("$dst")
  fi
done

echo "created  : ${created[*]:-none}"
echo "skipped  : ${skipped[*]:-none}"
echo
echo "Placeholders remain in CLAUDE.md, README.md, docs/prd.md and the CI"
echo "workflow. Fill every one — a shipped {{PLACEHOLDER}} is worse than no file."
