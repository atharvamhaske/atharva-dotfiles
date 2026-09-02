# atharva-dotfiles

Every AI agent I use — Claude Code, Codex, OpenCode — plus my actual shell setup, all living in
one repo and beamed onto `$HOME` with `stow`. The whole point: edit a file once, here, and it
shows up everywhere it needs to. No copying an AGENTS.md into twelve repos by hand, no "wait,
which version of this alias did I edit last."

Cursor doesn't play along, though — more on that below.

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

Quick note on `fzf`, `eza`, and `zoxide` — you won't find a config file for any of them here,
because they don't have one. All three just get `eval`'d into life inside `.zshrc`. If you're
looking for where fuzzy-finding or the fancy `ls` aliases come from, that's the one file to
check.

`.config/herdr/` on my actual machine is messier than what's tracked here — there's a
`session.json`, some log files, a `.plugins.lock`. All runtime junk, none of it belongs in
version control, so only `config.toml` made the cut.

And `.config/nvim/bin/brainrot-lsp`? That's a 6.5MB Linux binary sitting in a macOS config
directory — can't even execute on this machine. Some stray build artifact from who knows when.
Left it out entirely. Also worth knowing: `~/.config/nvim` already has its own `.git` pointed at
`jitesh117/nvim` — I didn't touch that. It just keeps existing, quietly, alongside this repo now
also tracking the same files through stow.

## What each agent reads

| Agent       | Global config              | Project config     | Skills   |
|-------------|-----------------------------|--------------------|----------|
| Claude Code | `~/.claude/CLAUDE.md`       | `./CLAUDE.md`      | `~/.claude/skills/*` |
| Codex       | `~/.codex/AGENTS.md`        | `./AGENTS.md`      | `~/.codex/skills/*` |
| OpenCode    | `~/.config/opencode/AGENTS.md` | `./AGENTS.md`   | `~/.config/opencode/skills/*` |
| Cursor      | *(User Rules — see below)*  | `.cursor/rules/*.mdc`, per repo | `~/.cursor/skills/*` |

Skills show up automatically for all four, in every repo, no setup required per project.
Claude / Codex / OpenCode get theirs via `stow`. Cursor gets the same flattened set written
straight into `~/.cursor/skills` by `link-skills.sh` — we do not stow `~/.cursor`, that tree
belongs to the app. All four still point at one source: `.agents/skills/<name>/SKILL.md`.

## Cursor is different

Cursor User Rules (Settings → Rules → User Rules) still live inside the app, not as a file
under `~/.cursor/`. Skills are a normal folder now (`~/.cursor/skills/`), and the linker
fills that in. User Rules stay a one-time paste:

- **Once per machine:** paste `.agents/AGENTS.md` into Settings → Rules → User Rules.
- **Per repo:** `.cursor/rules/*.mdc` if this project needs different behavior.

## Stowing

### First-time setup on a new machine

```bash
brew install stow
cd ~/Development/projects/atharva-dotfiles   # wherever you clone this repo
stow -n -v -t ~ .   # dry run — read the output first
stow -t ~ .         # apply
```

`stow` is polite about it — it only symlinks what actually lives in this repo, and if
`~/.claude/skills/` already has stuff in it from somewhere else (see "Coexisting with other
skill managers" further down), it merges in rather than steamrolling anything. The only thing
that trips it up is a genuine name collision.

`.stow-local-ignore` keeps `scripts/`, `.git`, `README.md`, and `.gitignore` from leaking into
`$HOME` — those are repo bookkeeping, not something you want symlinked into your home directory.

### After editing `.agents/AGENTS.md`

Nothing. Seriously — it's already symlinked everywhere, so the edit is live the moment you save.

### After adding, renaming, or removing a skill

```bash
./scripts/link-skills.sh   # regenerates .claude/skills/*, .codex/skills/*, .config/opencode/skills/*,
                            # ~/.cursor/skills/*, and .agents/skills/registry.json
```

No need to re-run `stow` just because a skill's *contents* changed — that's already flowing
through existing symlinks. `link-skills.sh` only needs to run again when the *set* of skills
changes (one gets added, renamed, or deleted). If `stow` complains about a new conflict after
that, just dry-run it again and see what it's upset about.

## Skills

Each skill lives in exactly one place: `.agents/skills/<name>/SKILL.md`, or one level deeper
under a grouping folder (`.agents/skills/review/pr-multi-agent-review/`) if it's the kind of
skill that's tied to a specific project or theme rather than something general-purpose.
`scripts/link-skills.sh` doesn't care how deep a skill is nested — it flattens everything into a
same-named symlink under each tool's `skills/` directory (Claude, Codex, OpenCode, and
`~/.cursor/skills`). That's the flat shape those tools expect. `registry.json` gets generated
from that pass — don't touch it by hand. Existing real directories already in
`~/.cursor/skills` (the golang pack, `ponyy`, …) are left alone.

## Coexisting with other skill managers

If you're also running `npx skills` (skills.sh), it's probably already claimed `~/.agents` for
itself, tracking everything through `~/.agents/.skill-lock.json`. That's a completely separate
system from this repo, and `stow` is built to get along with it rather than fight it — this
repo's `AGENTS.md` and skills just get added in as individual symlinks next to whatever `npx
skills` put there already. The only time you'll need to step in is a real name collision, and
even then it's a one-line fix: rename or remove one side through `npx skills` before you stow
again.

## Adding a new rule for all agents

1. Something universal? Edit `.agents/AGENTS.md` directly. Something scoped or trigger-based?
   New skill under `.agents/skills/<name>/SKILL.md`.
2. Added a skill → run `./scripts/link-skills.sh`.
3. Commit, push, done.

## What NOT to track

A bunch of machine-local stuff lives under `~/.claude/`, `~/.codex/`, and friends, and none of
it belongs in this repo: `auth.json` / `.credentials.json` (that's just secrets), `history.jsonl`
/ `sessions/` (your actual conversation history), `cache/` / `backups/` / `downloads/` (ephemeral
by definition), `settings.json` / `settings.local.json` (specific to this machine),
`*.sqlite` (local state), and `~/.agents/.skill-lock.json` — that one's `npx skills`' business,
not this repo's.
