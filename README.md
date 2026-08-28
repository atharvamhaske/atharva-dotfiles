# atharva-dotfiles

Centralized AI agent rules and skills for Claude Code, Codex, Cursor, and OpenCode. Everything
lives in this repo and gets projected onto `$HOME` with `stow` — no per-repo copying, no manual
symlinking, no vendor lock-in to any one tool.

## Layout

```
atharva-dotfiles/
├── .agents/                    # source of truth
│   ├── AGENTS.md                # canonical global instructions
│   └── skills/                  # every skill, one dir per skill (or grouped: review/, learn-codebase/, provider-kserve/)
│       └── registry.json        # generated index: name -> path -> description
├── .claude/
│   ├── CLAUDE.md → ../.agents/AGENTS.md
│   └── skills/*  → ../../.agents/skills/<name>   (flattened, one symlink per skill)
├── .codex/
│   ├── AGENTS.md → ../.agents/AGENTS.md
│   └── skills/*  → ../../.agents/skills/<name>
├── .cursor/rules/
│   └── global.md → ../../.agents/AGENTS.md
├── .config/opencode/
│   ├── AGENTS.md → ../../.agents/AGENTS.md
│   └── skills/*  → ../../../.agents/skills/<name>
└── scripts/
    └── link-skills.sh          # regenerates the flattened symlinks + registry.json
```

## What each agent reads

| Agent       | Global config              | Project config     |
|-------------|-----------------------------|--------------------|
| Claude Code | `~/.claude/CLAUDE.md`       | `./CLAUDE.md`      |
| Codex       | `~/.codex/AGENTS.md`        | `./AGENTS.md`       |
| Cursor      | `~/.cursor/rules/global.md` | Project Rules       |
| OpenCode    | `~/.config/opencode/AGENTS.md` | `./AGENTS.md`    |

All four ultimately point at the same file, `.agents/AGENTS.md`. Edit it once, every tool sees
the change immediately — no rebuild, no re-copy.

## Stowing

### First-time setup on a new machine

```bash
brew install stow   # or your package manager's equivalent
cd ~/Development/projects/atharva-dotfiles   # wherever you clone this repo
stow -n -v -t ~ .   # dry run first — read the output, make sure nothing unexpected is listed
stow -t ~ .         # apply
```

`stow` only ever creates symlinks for what's actually in this repo. It merges into existing
real directories rather than replacing them — if `~/.claude/skills/` already has content from
somewhere else (see "Coexisting with other skill managers" below), stow adds this repo's skills
alongside it rather than clobbering it, as long as no two skills share a name.

`.stow-local-ignore` excludes `scripts/`, `.git`, `README.md`, and `.gitignore` from being
projected into `$HOME` — those are repo-maintenance files, not agent config.

### After editing `.agents/AGENTS.md`

Nothing to do. It's already symlinked everywhere.

### After adding, renaming, or removing a skill

```bash
./scripts/link-skills.sh   # regenerates .claude/skills/*, .codex/skills/*, .config/opencode/skills/*
                            # and .agents/skills/registry.json
```

`stow` doesn't need to be re-run for skill *content* changes (those are already live through
existing symlinks) — only run `link-skills.sh` again when a skill directory is added, renamed,
or removed, since that's when the set of symlinks itself needs to change. If `stow` reports a new
conflict afterward, run the dry run again first.

## Skills

Every skill lives once, under `.agents/skills/<name>/SKILL.md` (or nested one level under a
grouping directory, e.g. `.agents/skills/review/pr-multi-agent-review/`, for skills that are
project- or theme-specific rather than general-purpose). `scripts/link-skills.sh` flattens every
skill it finds — regardless of nesting — into a same-named symlink directly under each tool's
`skills/` directory, since that's the shape Claude Code, Codex, and OpenCode expect for
discovery. `registry.json` is a generated index (name, path, description) — don't hand-edit it.

## Coexisting with other skill managers

`~/.agents` may already be used by `npx skills` (skills.sh) as its install directory, tracked
via `~/.agents/.skill-lock.json` — that's a separate, unrelated system from this repo, and stow
is designed to merge with it rather than take it over: this repo's `.agents/AGENTS.md` and each
of its own skills get added as individual symlinks alongside whatever `npx skills` has already
installed there. Only a genuine name collision between a skill in this repo and one installed by
`npx skills` needs manual resolution — pick one, and either rename or remove the other with
`npx skills` before re-stowing.

## Adding a new rule for all agents

1. Edit `.agents/AGENTS.md` directly for something universal, or add a new skill under
   `.agents/skills/<name>/SKILL.md` for something scoped/triggered.
2. If it's a new skill, run `./scripts/link-skills.sh`.
3. Commit and push.

## What NOT to track

These live under `~/.claude/`, `~/.codex/`, etc. but are machine-local state, never committed
here: `auth.json` / `.credentials.json` (secrets), `history.jsonl` / `sessions/` (conversation
history), `cache/` / `backups/` / `downloads/` (ephemeral data), `settings.json` /
`settings.local.json` (machine-specific), `*.sqlite` (local state databases), and anything under
`~/.agents/.skill-lock.json` (that belongs to `npx skills`, not this repo).
