# Explanation and code reasoning rules

These rules apply in every project. A project AGENTS.md can add rules. It does
not remove these rules.

## 1. First principles

- Start from the base facts: the constraints, the mechanism, the assumptions,
  and the invariants (conditions that must always stay true).
- Explain why a design works. Do not only say what it does.
- Do not use "this is the convention" as the reason. Give the mechanism that
  makes the convention correct, or say that no such mechanism exists.

Example. Question: "Why must a migration keep the old unique constraint?"

- Weak: "Expand/contract is the standard pattern."
- Correct: "The old code runs `ON CONFLICT (email)`. Postgres accepts this
  only if a unique index on `email` exists. During a rolling deploy, the old
  code and the new schema run at the same time. If the migration removes the
  index, the old code fails. Thus the index must stay until no old code runs."

## 2. Language

- Use ASD-STE100 Simplified Technical English. Use the `simple-english` skill
  for the full rule set. The most important rules:
  - Write a maximum of 20 words in a procedural sentence and 25 words in a
    descriptive sentence.
  - Use one word for one meaning. Do not change the term for the same thing.
  - Use the active voice and simple tenses.
  - Write one instruction in one sentence. Put a condition before the command.
- Define a term that is not common when you first use it.
- Use an example when it makes a concept clear.
- Remove AI writing patterns. Follow the `unslop` rules in
  `~/Development/projects/atharva-dotfiles/.agents/skills/unslop/SKILL.md`. The
  most important rules:
  - Do not use em dashes.
  - Use sentence case for headings.
  - Do not use filler ("It is important to note that"), hedges ("could
    potentially"), or chatbot phrases ("I hope this helps").
  - Use plain words ("use", not "leverage" or "utilize").
  - Write full sentences with articles and verbs. Do not compress text into
    symbols or fragments.

Example:

- Not STE: "The migration was run by the deploy, which could potentially cause
  issues for the legacy code paths."
- STE: "The deploy runs the migration. Then the old code fails."

## 3. Visual explanations

- If an explanation has many steps, branches, components, or interactions,
  include at least one diagram.
- Use only text for a simple fact or a one-step action.
- Use ASCII diagrams. They must show correctly in a terminal with a monospace
  font.

## 4. Data-flow diagrams

If you explain how data enters, moves through, changes in, or leaves a system,
include an ASCII data-flow diagram.

- Label each component, each data item, each transformation, and each flow
  direction.
- Show the important failure points.

Example:

```
 partner server                 CLD9 backend                      Postgres
 ┌────────────┐  POST /api/      ┌──────────────────────┐
 │ order JSON │─ partner/orders─►│ validate fields      │
 └────────────┘  X-Partner-Key   │  ├─ bad field ──► 400 │
                                 │ hash key → partner   │
                                 │  ├─ no match ──► 401 │
                                 │ write rows ──────────┼──► FORMULATION_INFO
                                 │                      ├──► CUSTOMER_INFO
                                 │                      └──► ORDER_INFO (CONFIRMED)
                                 └──────────────────────┘
```

## 5. Sequence diagrams

If you explain communication between two or more entities, include an ASCII
sequence diagram.

- Show the participants, the message direction, and the message order.
- Show requests, responses, errors, and retries when they apply.

Example:

```
 Machine                  CLD9 backend                Postgres
    │ GET /api/orders           │                         │
    │ X-Machine-Key: k1         │                         │
    │──────────────────────────►│ SELECT ... CONFIRMED    │
    │                           │────────────────────────►│
    │                           │◄────────────────────────│ rows
    │◄──────────────────────────│ 200 [orders]            │
    │                           │                         │
    │ GET /api/orders (no key)  │                         │
    │──────────────────────────►│                         │
    │◄──────────────────────────│ 401 Invalid machine key │
```

## 6. Code-change analysis

- Before you propose a change to a function, a method, or a class, read the
  code.
- Find the real callers and callees with search tools (`rg`, `grep`, LSP).
  Do not invent call paths.
- Show a call-path diff before and after the change. Mark each call as
  `[added]`, `[removed]`, or `[rerouted]`.
- Include only the frames that are related to the change.
- Describe the changes in behavior, the edge cases, and the compatibility
  risks.
- If you cannot find the full call graph in the code, say so. Name the part
  that you could not find.

Example (real paths from `CLD-Nine/Backend`):

```
Before:
partner_orders::create()
  └─► customer_info::upsert_by_email()        ON CONFLICT (email)

After:
partner_orders::create()
  ├─► customer_info::upsert_by_email()        [removed]
  └─► customer_info::upsert_for_partner()     [added]
        ON CONFLICT (partner_id, email) WHERE partner_id IS NOT NULL

Unchanged callers of upsert_by_email():
  customer::upsert(), webhooks::*, stripe_webhooks::*, ingredients::*
```

## 7. Technical explanations

For code that the reader does not know, explain these items in this order:

1. The problem that the code solves.
2. The mechanism that solves it.
3. The execution flow.
4. The design trade-offs.
5. The failure modes and the edge cases.

- For Go, Rust, and other compiled languages, tell which behavior occurs at
  compile time and which occurs at runtime. Example: "`sqlx::migrate!`
  includes the migration files in the binary at compile time. The binary
  applies them at runtime, when it starts."
- Give a small example that the reader can run, when it helps.

## 8. Accuracy

- Keep verified facts separate from assumptions. Label each assumption.
- Read the source code before you make a statement about how it works.
- Do not invent functions, callers, callees, outputs, or execution paths.
- If you did not run a command, do not show its output as real.
- Make the length of the explanation match the difficulty of the question.

Example:

- Verified: "`run_migrations()` calls `sqlx::migrate!(...).run()` with no
  `ignore_missing` (`crates/cld9-db/src/lib.rs:199`)."
- Assumption: "App Runner keeps the old instance until the new one is healthy.
  I did not test this in this account."
