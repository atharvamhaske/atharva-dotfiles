# atharva-dotfiles

AI agent rules/skills plus general shell/terminal config for macOS, all stowed onto `$HOME`
from this repo. No per-repo copying, no manual symlinking, no lock-in to one tool.

Cursor's the one holdout on the agent-config side — it has no on-disk global-rules file to
symlink into (see "Cursor is different" below) and no personal-skills concept at all.

## Layout

```
atharva-dotfiles/
├── .agents/                    # source of truth for agent config
│   ├── AGENTS.md                # canonical global instructions
│   └── skills/                  # one dir per skill (or grouped: review/, learn-codebase/, provider-kserve/)
│       └── registry.json        # generated index: name -> path -> description
├── .claude/
│   ├── CLAUDE.md → ../.agents/AGENTS.md
│   └── skills/*  → ../../.agents/skills/<name>   (flattened, one symlink per skill)
├── .codex/
│   ├── AGENTS.md → ../.agents/AGENTS.md
│   └── skills/*  → ../../.agents/skills/<name>
├── .config/opencode/
│   ├── AGENTS.md → ../../.agents/AGENTS.md
│   └── skills/*  → ../../../.agents/skills/<name>
├── .zshrc, .zprofile, .gitconfig   # shell + git config — plain files, this IS the source
├── .config/nvim/                   # NvChad-based nvim config
├── .config/ghostty/config          # terminal
├── .config/herdr/config.toml       # Herdr workspace/keybind config
├── .config/starship.toml           # prompt
└── scripts/
    └── link-skills.sh          # regenerates the flattened skill symlinks + registry.json
```

`fzf`, `eza`, and `zoxide` don't have config files of their own — all three are wired up inline
in `.zshrc` (shell integration, plus the `eza` and `f` aliases). Nothing to add for them beyond
that file.

`.config/herdr/` on disk also has `session.json`, log files, and `.plugins.lock`. Those are
runtime state, not config, so only `config.toml` is tracked here.

`.config/nvim/bin/brainrot-lsp` is a 6.5MB Linux binary that can't even run on macOS — a stray
build artifact, not config. Left out. The nested `.git` at `~/.config/nvim` (remote:
`jitesh117/nvim`) is untouched and stays separate; this repo just additionally tracks the same
files via stow symlinks.

## What each agent reads

| Agent       | Global config              | Project config     | Skills   |
|-------------|-----------------------------|--------------------|----------|
| Claude Code | `~/.claude/CLAUDE.md`       | `./CLAUDE.md`      | `~/.claude/skills/*` |
| Codex       | `~/.codex/AGENTS.md`        | `./AGENTS.md`      | `~/.codex/skills/*` |
| OpenCode    | `~/.config/opencode/AGENTS.md` | `./AGENTS.md`   | `~/.config/opencode/skills/*` |
| Cursor      | *(none — see below)*        | `.cursor/rules/*.mdc`, per repo | *(none)* |

Skills for the first three are automatic in every repo — no per-project setup. All three global
configs point at the same file, `.agents/AGENTS.md`; edit it once and every tool sees the change
immediately.

## Cursor is different

Cursor's global "User Rules" (Settings → Rules → User Rules) live as app state, not a file — so
there's nothing under `~/.cursor/` to symlink into, and no personal-skills directory either. Two
options, neither automatic:

- **One-time, not per-repo:** paste `.agents/AGENTS.md` into Settings → Rules → User Rules once
  per machine. It then applies everywhere, same as the other tools — this repo just can't push
  updates to it, since it's not a file.
- **Per-repo:** add `.cursor/rules/*.mdc` to a specific project for repo-scoped behavior. That's
  the directory's intended, supported use — project rules, not global ones.

## Stowing

### First-time setup on a new machine

```bash
brew install stow
cd ~/Development/projects/atharva-dotfiles   # wherever you clone this repo
stow -n -v -t ~ .   # dry run — read the output first
stow -t ~ .         # apply
```

`stow` only symlinks what's actually in this repo, and merges into existing real directories
rather than replacing them. If `~/.claude/skills/` already has content from elsewhere (see
"Coexisting with other skill managers"), stow adds this repo's skills alongside it — as long as
nothing shares a name.

`.stow-local-ignore` keeps `scripts/`, `.git`, `README.md`, and `.gitignore` out of `$HOME` —
repo-maintenance files, not config.

### After editing `.agents/AGENTS.md`

Nothing to do — it's already symlinked everywhere.

### After adding, renaming, or removing a skill

```bash
./scripts/link-skills.sh   # regenerates .claude/skills/*, .codex/skills/*, .config/opencode/skills/*
                            # and .agents/skills/registry.json
```

`stow` doesn't need a re-run for skill *content* changes — those are already live through
existing symlinks. Only re-run `link-skills.sh` when the skill directory *set* changes (added,
renamed, removed). If `stow` then reports a new conflict, dry-run it again.

## Skills

Every skill lives once, under `.agents/skills/<name>/SKILL.md` — or nested a level deeper under
a grouping dir (`.agents/skills/review/pr-multi-agent-review/`) for skills that are project- or
theme-specific rather than general-purpose. `scripts/link-skills.sh` flattens every skill it
finds, regardless of nesting, into a same-named symlink under each tool's `skills/` dir, since
that's the shape Claude Code, Codex, and OpenCode need for discovery. `registry.json` is
generated — don't hand-edit it.

## Coexisting with other skill managers

`~/.agents` may already belong to `npx skills` (skills.sh), tracked via
`~/.agents/.skill-lock.json` — a separate system from this repo. `stow` merges with it instead of
taking it over: this repo's `AGENTS.md` and skills get added as individual symlinks alongside
whatever `npx skills` already installed. Only a real name collision needs manual resolution —
rename or remove one side with `npx skills` before re-stowing.

## Adding a new rule for all agents

1. Edit `.agents/AGENTS.md` for something universal, or add a skill under
   `.agents/skills/<name>/SKILL.md` for something scoped/triggered.
2. New skill → run `./scripts/link-skills.sh`.
3. Commit and push.

## What NOT to track

Machine-local state under `~/.claude/`, `~/.codex/`, etc. that never gets committed: `auth.json`
/ `.credentials.json` (secrets), `history.jsonl` / `sessions/` (conversation history), `cache/` /
`backups/` / `downloads/` (ephemeral), `settings.json` / `settings.local.json`
(machine-specific), `*.sqlite` (local state), and `~/.agents/.skill-lock.json` (belongs to
`npx skills`, not this repo).
