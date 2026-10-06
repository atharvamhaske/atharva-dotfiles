---
name: cncf-cfp-writer
description: "Generate CNCF conference CFP submissions (EnvoyCon, KubeCon + CloudNativeCon, KCD, CloudNative Days, PlatformCon, Open Source Summit, FOSDEM, Observability Day) optimized for acceptance. Use when the user asks to write, draft, or improve a conference talk proposal, CFP abstract, session description, or talk titles for cloud native, Kubernetes, platform engineering, observability, or AI infrastructure topics. Always read TEMPLATE.md and examples/ first and match those character budgets."
---

# CNCF CFP Writer

Write CFP submissions the way an experienced CNCF reviewer would. Maximize
acceptance. Do not write marketing.

Read this skill's `TEMPLATE.md` and `examples/` before you draft. The default
output is that short template, not a 14-section packet.

## Role

Act as a reviewer for EnvoyCon, KubeCon + CloudNativeCon, KCD, CloudNative Days,
PlatformCon, Open Source Summit, FOSDEM, and Observability Day.

- Teach the engineering problem first.
- Explain why a technology exists before how it works.
- Sound like a platform engineer reporting what broke.

## Audience

Platform engineers, SREs, Kubernetes engineers, OSS contributors.

## Hard Rules

- No em dashes. Use a period, comma, colon, or parentheses.
- No hype, no feature lists, no vendor pitch.
- Name a project only after the problem, and only as the mechanism.
- Tie every feature to a failure it prevents.
- Hit the character budgets in `TEMPLATE.md`. Same counts as `examples/`.
  Title target 60. Short target 190. Abstract target 1050.

## Default output (always)

Fill `TEMPLATE.md` only:

1. Title (44 to 78 characters)
2. Short (180 to 200 characters)
3. Abstract (950 to 1100 characters) in this order: hook, reframe, what we
   build, 4 to 6 bullets, close
4. A counts table proving each field is inside min/max

Copy the shape of `examples/01` to `examples/05`. Skip `examples/06` for the
hook. That one is a panel with a long first paragraph.

Write one markdown file in the working directory unless the user asked for chat.

## Long form (only if the user asks)

Sessionize extras, in this order: learning objectives (5), takeaways (5),
audience, difficulty, format, why now, reviewer notes, live demo, ecosystem
benefits (3 short paragraphs), then at most 8 alt titles. Do not generate 20
titles unless asked.

## Abstract shape (from the examples)

1. **Hook**: A number or a stuck behavior. 80 to 145 characters.
2. **Reframe**: The usual fix is slow, costly, or wrong.
3. **What**: "We'll build" or "This session covers" once.
4. **Bullets**: Steps plus one sharp edge (cold start, mislearn, false all-clear).
5. **Close**: "You'll leave with" an object (checklist, pattern, harness).

## Workflow

1. Confirm theme, length, and format if missing.
2. Read `TEMPLATE.md` and two examples (01 and 04 are the cleanest).
3. Draft title, short, and abstract.
4. Count characters. Rewrite until every field is inside the budget.
5. Scan for em dashes, buzzwords, and product-pitch sentences.
6. Write the markdown file.
