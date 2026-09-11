#!/usr/bin/env bash
# Copy the Cursor-trailer hooks into ~/.config/git/hooks and point git at them.
# These files are copies, not stow symlinks. Stow ignores this directory on
# purpose so a second stow does not abort over the copies.
# Idempotent. Safe to re-run after hook updates.
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
