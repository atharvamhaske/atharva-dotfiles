# CFP template (short form)

Copy this shape. Hit the character budgets. Do not add extra sections.

Budgets come from `examples/` (talks 1 to 5). Talk 6 is a panel and is longer in the hook; do not copy that.

| Field | Min | Max | Target |
| --- | ---: | ---: | ---: |
| Title | 44 | 78 | 60 |
| Short (Sessionize blurbs) | 180 | 200 | 190 |
| Hook (first paragraph) | 80 | 145 | 120 |
| Full abstract (no title) | 950 | 1100 | 1050 |
| Close (last paragraph) | 55 | 180 | 120 |
| Cover bullets | 4 | 6 | 5 |

Count with `wc -m` or `len()`. If a field is short, add one concrete failure. If it is long, cut a clause. Do not ship outside the min/max.

---

## Title

`[concrete object]: [what you do to it]`

or first person: `I [did X]: [the real method]`

---

## Short (180 to 200 characters)

One pain. One mechanism. One leave-with. No bullet list. No vendor pitch.

```
[HOOK]. [WHAT YOU BUILD]. You'll leave with [OBJECT].
```

---

## Abstract (950 to 1100 characters)

```
[HOOK: stat or frozen behavior. 80-145 chars]

[REFRAME: the usual fix is slow, costly, or wrong. 80-160 chars]

[WHAT: This session / We'll build / In this lab. Name the pipeline, not the brand. 180-280 chars]

What we'll cover:
- [step or sharp edge]
- [step or sharp edge]
- [step or sharp edge]
- [step or sharp edge]
- [failure mode or when not to do this]

[CLOSE: You'll leave with [checklist / pattern / harness]. Includes a live demo if true. 55-180 chars]
```

---

## Rules taken from the examples

1. Open with a number or a stuck behavior. Not "In this talk we will explore."
2. Name the usual fix and why it fails, then the cheaper path.
3. "We'll build" or "This session covers" once. Then bullets.
4. Last line is an object the attendee can take home.
5. One honest failure mode in the bullets (cold start, mislearn, agent waving through a CVE).
6. Project names appear only as the mechanism. Never as the plot.
7. No em dashes. No "we're excited." No 20 title variants unless asked.

---

## After you fill

Print the counts. Rewrite until every row is inside min/max. Write one markdown file unless the user asked for chat.
