#!/usr/bin/env bash
# solodev installer — copies three skills to your Claude Code skills directory.
# Usage:
#   ./install.sh              → install globally (~/.claude/skills/)
#   ./install.sh --project    → install for current project (.claude/skills/)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/skills"

if [[ ! -d "$SRC" ]]; then
  echo "✖  skills/ directory not found at $SRC" >&2
  exit 1
fi

MODE="${1:-global}"

case "$MODE" in
  --project|project|-p)
    DEST="$(pwd)/.claude/skills"
    SCOPE="project ($(pwd))"
    ;;
  --global|global|"")
    DEST="${HOME}/.claude/skills"
    SCOPE="global (~/.claude/skills/)"
    ;;
  -h|--help|help)
    echo "Usage:"
    echo "  $0              install globally to ~/.claude/skills/"
    echo "  $0 --project    install to ./.claude/skills/ (current project)"
    exit 0
    ;;
  *)
    echo "✖  Unknown option: $MODE" >&2
    echo "Run '$0 --help' for usage." >&2
    exit 1
    ;;
esac

mkdir -p "$DEST"

echo "→ Installing solodev skills to: $SCOPE"
echo

for skill in dev-brainstorm dev-plan dev-coding; do
  if [[ -d "$DEST/$skill" ]]; then
    echo "  ✓ $skill (overwriting existing)"
  else
    echo "  ✓ $skill"
  fi
  rm -rf "$DEST/$skill"
  cp -r "$SRC/$skill" "$DEST/$skill"
done

echo
echo "✓ Installed. In Claude Code, type / and you should see:"
echo "    /dev-brainstorm"
echo "    /dev-plan"
echo "    /dev-coding"
echo
echo "Workflow: /dev-brainstorm → /dev-plan → [reset context] → /dev-coding"
