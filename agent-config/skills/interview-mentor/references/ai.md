# AI / Agent Engineering Reference

Working notes on evaluating, observing, benchmarking, sandboxing, and durably running LLM agents in production — the discipline that's emerged around "the agent works in the demo, does it work at 3am with a flaky tool call." Useful for Day B/C problems shaped around agentic systems rather than classic CRUD backends.

## Evals vs. observability vs. monitoring vs. benchmarking — four different jobs

These get used interchangeably in casual conversation but answer different questions, and a mature setup needs all four:

- **Benchmarks** answer "how does this agent/model compare to alternatives," run against a fixed, usually public, task suite — useful for model/config selection, not for catching your specific production regressions.
- **Evals** answer "is this specific agent good enough to ship / keep running," usually a mix of offline evaluation against a curated golden set of question-answer or task-outcome pairs, and online evaluation sampled from live traffic.
- **Observability** answers "why did this specific run fail" — makes an individual agent trajectory inspectable: which tools were called, with what arguments, what the model saw at each step, where it looped or backtracked.
- **Monitoring** answers "is quality degrading right now, in aggregate" — dashboards/alerts over eval-derived metrics tracked over time, so a model or prompt regression is caught before a human notices complaints.

The common failure mode worth knowing for interviews: teams stop at a held-out benchmark plus a single final-answer pass/fail metric, which misses trajectory quality (did it use the right tools, in the right order), tool-call correctness (right arguments, not just "a tool was called"), infinite-looping, and recovery behavior after a failed tool call — all of which matter far more to a real user's experience than whether the final string matched.

## What "trajectory" evaluation actually checks

An agent's trajectory is the full sequence of thoughts/tool-calls/observations across a task, not just the final output. Trajectory-level evals typically score:

- **Tool selection** — did it pick the right tool for the sub-task, not just *a* tool.
- **Argument correctness** — right tool, wrong arguments is a distinct and common failure class (e.g. correct API called with a malformed or hallucinated parameter).
- **Step efficiency** — did it take a reasonable number of steps, or did it loop/backtrack unnecessarily (a real cost driver at scale, since every step is inference spend).
- **Recovery** — after a tool call errors or returns unexpected data, does it adapt, or does it retry the identical failing call indefinitely (a real production failure mode, and a good interview probe: "what happens if a tool your agent depends on starts returning malformed JSON").

## Sandbox agents

A sandbox is an isolated execution environment (container, microVM, or similar) where an agent can run arbitrary code / shell commands / file operations without touching the host or other tenants' data. The design questions that actually matter operationally:

- **Isolation boundary** — process-level, container-level, or VM-level, trading startup latency against blast-radius if the isolation is imperfect. A fresh microVM per session is safer but slower to spin up than a shared container pool with per-session working directories.
- **Lifecycle** — ephemeral (destroyed after each task, clean but loses any accumulated state/cache) vs. persistent-per-session (faster warm starts, but now you're managing sandbox state and eventual cleanup/expiry).
- **Resource limits** — CPU/memory/network egress caps per sandbox are the actual security-relevant control, not just "it's isolated" — an agent that can make unbounded outbound network calls from inside its sandbox can still exfiltrate data or be used as an attack proxy even without host access.
- **Provider-swappability** — production agent platforms increasingly treat the sandbox as a pluggable backend (local Docker for dev, a hosted microVM service for prod) rather than hardcoding one implementation, since sandbox cost/latency/isolation trade-offs differ by workload.

## Durable agents (Temporal-style durable execution)

The problem durable execution solves: a long-running agent workflow (minutes to days — waiting on a human approval, a slow external job, a scheduled follow-up) needs to survive process crashes, deploys, and restarts *without* losing its place or re-running side effects that already happened.

**How it works, conceptually:** the workflow's code executes step by step, but every step's result is recorded in an event history. If the worker process crashes and restarts, the workflow *replays* from the event history — re-executing the workflow function, but each already-completed step (an "activity" — the durable-execution term for a side-effecting operation like an API call) returns its previously recorded result instantly instead of re-running, until replay catches up to where execution actually left off, at which point it resumes for real. This gives you crash recovery and exactly-once *effect* semantics for the workflow's individual steps without a hand-rolled checkpoint/resume system.

**Why this matters specifically for agents:** an agent loop is naturally long-running and step-structured (think → call tool → observe → think again), which maps directly onto the workflow/activity model — each tool call is an activity, the reasoning loop is the workflow. This buys you: automatic retry of a failed tool call with backoff (a workflow feature, not custom code), human-in-the-loop pauses that can last arbitrarily long (the workflow just waits for a signal) without holding a thread or process open, and full replayable history for debugging exactly what an agent did and why, at each step, after the fact.

**The gotcha interviewers probe for:** workflow code must be *deterministic* (same inputs always produce the same sequence of decisions on replay) — anything nondeterministic (current time, random numbers, direct network/DB calls) must happen inside an activity, not directly in workflow code, or replay will diverge from what actually happened and corrupt the workflow's state.

## Practical interview framing

A good Day B/C problem in this space: "your agent platform serves 10K concurrent user sessions, each running a multi-step tool-using agent; p95 task completion time just went from 8s to 40s, and support says some agents 'get stuck.'" That's a real production shape — the reasoning path runs through trajectory-level observability (where in the loop is time going), tool-call latency/timeout configuration, whether retries are compounding (a slow tool + naive retry logic looks exactly like "stuck"), and whether the sandbox/execution layer itself has become the bottleneck (cold-start latency under load) rather than the model.

## Sources consulted while writing this file

- Live 2026 web search on agent evaluation/observability/benchmarking/sandbox/durable-execution framing (see conversation for the specific queries and result links); synthesized and reframed here rather than quoted.
