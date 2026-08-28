# agent-config

One canonical `AGENTS.md` for AI coding agents, wired into Claude Code, Codex CLI, and Cursor without copying the text into every repo.

## Layout

```
agent-config/
  AGENTS.md            canonical, universal principles
  CLAUDE.md.example     the two lines every repo's CLAUDE.md needs
```

## Global setup, once per machine

Each tool has its own "apply everywhere" layer. Point them all at the same file so there is one place to edit.

```bash
ln -s ~/agent-config/AGENTS.md ~/.claude/CLAUDE.md
ln -s ~/agent-config/AGENTS.md ~/.codex/AGENTS.md
ln -s ~/agent-config/AGENTS.md ~/.cursor/rules/global.md
```

Check the Cursor line against your installed version. Some versions store User Rules purely through Settings > Rules > User Rules rather than a plain file; if the symlink is not picked up, paste `AGENTS.md`'s contents into that settings panel instead.

## Per-repo setup

Commit `AGENTS.md` at the root of each project, extended with anything specific to that project or stack. Codex and Cursor read it natively. For Claude Code, add a two-line `CLAUDE.md` next to it:

```
@AGENTS.md
```

That is the whole file, unless you want Claude-specific additions below the import line, as shown in `CLAUDE.md.example`.

### Keeping the per-repo copy in sync

Copying `AGENTS.md` into every repo works, but it drifts. Two ways to avoid that:

1. Add this repo as a git submodule at `.agent-config/` in each project, then symlink the root file into it:
   ```bash
   git submodule add https://github.com/you/agent-config .agent-config
   ln -s .agent-config/AGENTS.md AGENTS.md
   ```
   Pull the submodule to update; every repo picks up changes the same way.

2. Skip submodules and just re-copy `AGENTS.md` by hand when it changes, extending each copy with that repo's own rules. Simpler if you only maintain a handful of repos and the shared content does not change often.

### Stack-specific additions

Keep the shared `AGENTS.md` universal. Add anything stack-specific directly to that repo's own copy, for example:

```markdown
## Go

Always use the gopls-lsp MCP server for diagnostics, go-to-definition,
find-references, and symbol lookups. Prefer it over manual grep or glob
for Go-specific operations.
```

For monorepos with per-language subdirectories, both Codex and Cursor also read a nested `AGENTS.md` placed inside that subdirectory instead, so the stack-specific block only loads for agents working in that part of the tree.
