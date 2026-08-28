---
name: conventional-commits
description: Drafts git commit messages that follow the Conventional Commits v1.0.0 spec (https://www.conventionalcommits.org/en/v1.0.0/), lints every draft with commitlint (run via bun, using the target repo's own commitlint config when it has one — so a pass here means CI will pass too) via the bundled scripts/validate-commit-msg.sh, and fixes any reported violations before handing back the final message. Use this any time the user wants a commit message written or formatted for staged changes, invokes /conventional-commits, mentions "conventional commits", asks you to look at `git diff --cached`, wants a commit message that passes commitlint, or just asks something like "write me a commit message for this" or "what should I call this commit" — even without those exact words.
compatibility: Requires git and bun (https://bun.sh) on PATH. bun installs commitlint automatically on first use. Clipboard copy via pbcopy is macOS-only and optional.
---

# Conventional Commits

Drafts a [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)-formatted message for the user's **staged** changes, lints it with `commitlint` so it's guaranteed to pass the same checks CI runs, fixes anything flagged, and hands back the final message. This skill never runs `git commit` itself — only draft and validate, unless the user explicitly asks for the commit to actually happen.

## Workflow

1. **Look only at staged changes.** Run `git diff --cached` to see exactly what will be committed. Don't look at the unstaged working-tree diff or untracked files unless the user explicitly asks you to include them — the message should describe what's actually staged, not other work sitting in the tree that may not even be part of this commit.

   If `git diff --cached` is empty, say so and ask the user to stage something rather than inventing a message.

2. **Draft the message.**
   - Subject line: `<type>(<scope>): <description>`, imperative mood, no trailing period, ideally under ~72 characters.
   - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`. Pick the one that actually matches the diff — don't default to `feat` for something that's really a `fix` or `chore`.
   - Scope is optional; infer it from the changed paths when the diff clearly centers on one module or package.
   - Body: Markdown formatting, with file names, identifiers, flags, and code in backticks. If the staged diff bundles several unrelated changes, don't blend them into one paragraph — use bullet points or separate lines, one per logical change, so it's clear at a glance what each change is.
   - Add a `BREAKING CHANGE:` footer if the diff includes a breaking change.

3. **Lint it.** Write the draft to a temp file and run:
   ```
   scripts/validate-commit-msg.sh <path-to-message-file> <path-to-repo>
   ```
   `<path-to-repo>` is the repo the commit is for (defaults to the current directory if omitted). The script:
   - Installs `commitlint` via `bun` into `~/.cache/conventional-commits-skill` the first time it's ever run on this machine; every run after that is offline and near-instant.
   - Lints against **the target repo's own commitlint config** if it has one (`commitlint.config.js`/`.cjs`/`.mjs`/`.ts`, `.commitlintrc*`, or a `"commitlint"` key in `package.json`) — this is what makes a clean result here mean CI will also pass. If the repo defines no config of its own, it falls back to `@commitlint/config-conventional`.
   - Exits `0` with no output when the message is clean; otherwise prints commitlint's violation report and exits non-zero.

4. **Fix and re-lint.** If the script reports problems, revise the message and run it again. Keep iterating until it exits clean — don't hand the user a message that would fail CI.

5. **Present the result.** Output the final message as-is, in Markdown, with code in backticks. Do not run `git commit` unless the user explicitly asked for that.
   - If the user asked you to copy it to the clipboard and you have shell access with `pbcopy` available (macOS, interactive session), pipe the final message to it.
   - In non-interactive contexts (e.g. `claude -p`, single-shot mode with no clipboard to write to), just print the message so the caller can pipe it themselves (`| pbcopy && gcmt`, for example) — don't attempt `pbcopy` there even if asked, since it has nothing to write to; say so instead.

## Notes

- If `bun` isn't installed, the script fails with a clear error pointing to https://bun.sh — don't silently substitute `npm`/`npx`, since the shared-cache-on-first-run behavior described above is specifically a `bun` feature.
- The commitlint install lives in a machine-wide cache (`~/.cache/conventional-commits-skill`), not inside the target repo, so it never touches the user's `package.json` or lockfile.

## Example invocations this skill should handle

**Interactive (Claude Code / Claude.ai):**
> look at the cached diff using `git diff --cached` **only**, don't look at the uncached changes, and write a commit message. Don't commit yourself, just output the message and copy it to clipboard using pbcopy. Keep the format as markdown, so that code is in backticks. Always use bullets or separate lines when the changes are not related.

**Non-interactive (`claude -p`):**
> ...write the commit message as-is that I can pipe to pbcopy and commit...

Both should produce the same drafting → lint → fix → present workflow above; the only difference is whether the skill itself invokes `pbcopy` (interactive) or just prints the message for the caller to pipe (non-interactive, per the note above).
