---
name: pr-description
description: Generate a PR description by summarizing commits and diffs on the current branch. Use when user asks to generate, write, create, draft, or summarize a PR description, or asks "what changed in this PR" or "describe these changes".
allowed-tools: Bash, Read, Write, Glob, Grep
---

# Generate PR Description

Analyze the current branch's commits and diffs against the default branch, optionally use a PR template, and output a well-formatted PR description — with a suggested [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)-style title, since most squash-merge workflows turn the PR title into the commit message that lands on the default branch.

## Step 1: Determine the default branch

Try to find the default branch name:

```bash
git rev-parse --verify main >/dev/null 2>&1
```

If `main` exists, set `DEFAULT_BRANCH=main`.

Otherwise, try `master`:

```bash
git rev-parse --verify master >/dev/null 2>&1
```

If `master` exists, set `DEFAULT_BRANCH=master`.

If neither exists, try to detect via the remote HEAD:

```bash
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'
```

If this returns a branch name, use that as `DEFAULT_BRANCH`.

If no default branch can be determined, report "❌ Could not determine the default branch (tried main, master, and origin HEAD)" and stop.

## Step 2: Gather commits and diffs

Run the following commands to collect change information:

1. Full commit log with diffs (for deep analysis):

   ```bash
   git log $DEFAULT_BRANCH..HEAD -p --reverse
   ```

2. File change summary (for the overview):

   ```bash
   git diff $DEFAULT_BRANCH..HEAD --stat
   ```

3. One-line commit list (for reference):

   ```bash
   git log $DEFAULT_BRANCH..HEAD --format="%h %s"
   ```

4. Which of those commit subjects are already Conventional-Commits-formatted (this tells you how much of the typing/scoping work is already done for you):

   ```bash
   git log $DEFAULT_BRANCH..HEAD --format="%s" | grep -E "^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?!?:"
   ```

If no commits are found between `$DEFAULT_BRANCH` and HEAD (i.e., the output of command 1 is empty), report "❌ No commits found between $DEFAULT_BRANCH and HEAD. Make sure you are on a feature branch with commits ahead of $DEFAULT_BRANCH." and stop.

## Step 3: Search for a PR template

Check for a PR template in these locations, in priority order, using the Glob tool:

1. `.github/PULL_REQUEST_TEMPLATE.md`
2. `.github/pull_request_template.md`
3. `PULL_REQUEST_TEMPLATE.md` (repo root)
4. `pull_request_template.md` (repo root)
5. `docs/PULL_REQUEST_TEMPLATE.md`
6. `docs/pull_request_template.md`
7. `.github/PULL_REQUEST_TEMPLATE/` directory (if it exists, list all `.md` files inside and use the first one)

Use glob patterns like `**/{PULL_REQUEST_TEMPLATE,pull_request_template}.md` to search efficiently.

If a template is found, read its contents with the `Read` tool. If multiple templates are found (e.g., in `.github/PULL_REQUEST_TEMPLATE/`), use the first one and note which template was used.

If no template is found, that is fine — proceed with the default format in Step 4.

A template, if found, only governs the **body**. The suggested title in Step 4a always applies on top of it, since GitHub tracks the PR title separately from the body and a template has no way to express it.

## Step 4a: Derive a Conventional-Commits-style title

Whether or not a template was found, work out a single title in the form `type(scope): description` that summarizes the PR as a whole — this is what a squash-merge will turn into the actual commit message on `$DEFAULT_BRANCH`, so it's worth getting right even when the body follows a completely different, repo-specific format.

- **Type**: the same taxonomy as Conventional Commits — `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`. If the per-commit check in Step 2.4 shows most commits already carry a type, that's a strong signal for the overall type; when commits disagree (e.g. a `feat` plus a couple of `fix`es for bugs introduced along the way), pick the type that best describes the PR's primary purpose — a feature branch with a few self-fixes is still a `feat`, not a `fix`.
- **Scope**: optional; infer it from the diff's file paths when the change clearly centers on one module or package. Omit it when the PR touches many unrelated areas rather than guessing.
- **Description**: imperative mood, no trailing period, ideally under ~72 characters total for the whole title.
- If the change is breaking, note that in the description or flag it to the user — Conventional Commits marks this with a `!` before the colon (`feat(api)!: ...`) — but don't add a `BREAKING CHANGE:` footer to the *title*; that belongs in the body/footer if the repo's template has a place for it.

**Optionally lint the title.** If `bun` is available on `PATH`, write the title to a temp file and run `scripts/validate-commit-msg.sh <path-to-message-file> <path-to-repo>` to check it against commitlint (the repo's own config if it has one, otherwise `@commitlint/config-conventional` — see the script's comments for details). Fix and re-check until it's clean. If `bun` isn't installed, skip this and present the title as-is without claiming it was linted — don't block PR description generation on a missing optional dependency.

## Step 4b: Compose the PR description body

Analyze all commits and diffs gathered in Step 2. The description should cover:

- **WHAT** changed — a clear summary of the modifications
- **WHY** — the motivation or purpose behind the changes (inferred from commit messages and code context)
- **HOW** — for non-trivial changes, briefly explain the approach or implementation strategy
- **Impact/Scope** — which areas of the codebase are affected

**If a PR template was found in Step 3:**

- Fill in each section of the template based on the commit and diff analysis
- For checkbox items (e.g., `- [ ] Tests added`), check them (`- [x]`) ONLY if the diffs clearly confirm the criteria is met
- Do NOT remove or skip any sections from the template — fill them all in, even if a section is "N/A"
- Preserve the template's formatting and structure exactly
- MUST wrap all code references in backticks (see Formatting rule below)

**If no PR template was found:**

Use this default format:

```markdown
## Summary

<1-3 sentence high-level summary of the changes>

## Changes

<Group changes under Conventional-Commits-style headings, omitting any heading with nothing under it: Features, Bug Fixes, Performance, Refactoring, Documentation, Tests, Build, CI, Style, Chores, Reverts. Within each heading, use bullet points grouped logically by theme or component, NOT one bullet per commit — combine related commits into coherent descriptions.>

## Test Plan

<Describe how the changes can be tested, or note if tests were added/modified>
```

Use the per-commit types from Step 2.4 to sort changes into headings where a commit is already typed; for untyped commits (or squashed/mixed commits touching several concerns), classify each logical change from the diff the same way you derived the overall type in Step 4a. This keeps the body's grouping consistent with the title's type instead of the two disagreeing.

**Important:** Whether grouped by template section or by these headings, never do one bullet per commit — combine related commits into coherent, theme-level change descriptions.

**Formatting (MANDATORY):** You MUST wrap ALL code references in backticks (`` ` ``). This includes: file names (e.g., `e2e/cache.go`), function names (e.g., `createVMExtensionLinuxAKSNode`), variable names, struct names, interface names, type names, method names, package names, commands, config keys, error messages, and any other identifier from the code. Every reference to something in the codebase must be wrapped in backticks — no exceptions. The output is used as a GitHub PR description where markdown rendering depends on this.

## Step 5: Output the result

**Default behavior:** Output the suggested title (from Step 4a) followed by the PR description body (from Step 4b) as formatted markdown directly to the user. Do NOT post it to GitHub unless explicitly asked.

After outputting the description, save it to a temp file so the user can copy the raw markdown (the terminal rendering strips backticks):

1. Create a temp file:

   ```bash
   mktemp --suffix=.md
   ```

2. Write the generated title and description markdown to that file using the Write tool.

3. Tell the user: `📄 PR description also saved to: <path>` so they can copy the raw markdown from the file.

**If the user explicitly asks to update/post the PR** (e.g., the user said "update the PR", "post it", "apply it to the PR", or invoked with arguments like "update"):

1. Check for an open PR on the current branch:

   ```bash
   gh pr view --json number,url 2>/dev/null
   ```

2. If no open PR exists, report "❌ No open PR found for the current branch. Push your branch and create a PR first, or use `gh pr create`." and stop.

3. If an open PR exists, update both the title and body:

   ```bash
   gh pr edit --title "<generated title from Step 4a>" --body "<generated description from Step 4b>"
   ```

4. Report "✅ PR description updated: <PR URL>" on success.
