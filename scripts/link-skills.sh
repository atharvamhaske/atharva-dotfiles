#!/usr/bin/env bash
# Flattens every skill under .agents/skills/**/SKILL.md into a same-named
# symlink under each tool's skills/ dir (.claude, .codex, .config/opencode)
# plus $HOME/.cursor/skills (Cursor's personal dir — not stowed, ~/.cursor
# is the app tree). Regenerates .agents/skills/registry.json. Idempotent.
# Run from the repo root.
set -euo pipefail

cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"
SKILLS_SRC="$REPO_ROOT/.agents/skills"

declare -a TARGETS=(".claude/skills" ".codex/skills" ".config/opencode/skills")

for t in "${TARGETS[@]}"; do
  mkdir -p "$t"
  find "$t" -maxdepth 1 -type l -delete
done

# Only our symlinks. Leave real dirs (cc-skills-golang, ponyy, …) alone.
HOME_CURSOR=""
if [[ -d "${HOME}/.cursor" ]]; then
  HOME_CURSOR="${HOME}/.cursor/skills"
  mkdir -p "$HOME_CURSOR"
  find "$HOME_CURSOR" -maxdepth 1 -type l -delete
fi

registry_entries=()

while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_dir")"
  rel_from_repo="${skill_dir#"$REPO_ROOT"/}"

  for t in "${TARGETS[@]}"; do
    depth=$(($(grep -o "/" <<<"$t" | wc -l) + 1))
    prefix=""
    for ((i = 0; i < depth; i++)); do prefix="../$prefix"; done
    ln -sfn "${prefix}${rel_from_repo}" "$t/$skill_name"
  done

  if [[ -n "$HOME_CURSOR" ]]; then
    dest="$HOME_CURSOR/$skill_name"
    if [[ -e "$dest" && ! -L "$dest" ]]; then
      echo "skip Cursor: $dest exists and is not a symlink" >&2
    else
      ln -sfn "$skill_dir" "$dest"
    fi
  fi

  desc="$(sed -n 's/^description: *//p' "$skill_md" | head -1 | sed 's/^"//;s/"$//;s/|$//')"
  registry_entries+=("  \"$skill_name\": {\"path\": \"skills/${rel_from_repo#.agents/skills/}\", \"description\": $(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$desc")}")
done < <(find "$SKILLS_SRC" -name SKILL.md | sort)

{
  echo "{"
  IFS=$'\n' sorted=($(printf '%s\n' "${registry_entries[@]}" | sort))
  for i in "${!sorted[@]}"; do
    sep=","
    [ "$i" -eq $((${#sorted[@]} - 1)) ] && sep=""
    echo "${sorted[$i]}$sep"
  done
  echo "}"
} > "$SKILLS_SRC/registry.json"

echo "Linked ${#registry_entries[@]} skills into: ${TARGETS[*]}"
if [[ -n "$HOME_CURSOR" ]]; then
  echo "Linked ${#registry_entries[@]} skills into: $HOME_CURSOR"
else
  echo "skip Cursor: $HOME/.cursor is missing"
fi
echo "Wrote $SKILLS_SRC/registry.json"
