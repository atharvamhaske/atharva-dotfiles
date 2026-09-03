#!/usr/bin/env bash
# Point global git at ~/.config/git/hooks (stowed from this repo).
# Idempotent — safe to re-run after stow or hook updates.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_ROOT/.config/git/hooks"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/git/hooks"

if [[ ! -d "$SRC" ]]; then
  echo "missing hooks source: $SRC" >&2
  exit 1
fi

mkdir -p "$DEST"
for hook in prepare-commit-msg commit-msg; do
  install -m 755 "$SRC/$hook" "$DEST/$hook"
done

git config --global core.hooksPath "~/.config/git/hooks"
echo "core.hooksPath=$DEST"
echo "Hooks installed. Cursor/AI commit trailers are stripped and blocked."
