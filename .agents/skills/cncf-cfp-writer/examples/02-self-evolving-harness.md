# Make Your Agent Harness Self-Evolving with Persistent Memory

Your agent keeps repeating the same mistakes. Ship it, and its behavior is frozen- every improvement has to come from you.

Retraining is the usual fix: slow, costly, and overkill for "remember what worked last time."

In 2026 a cheaper path took over: let the agent rewrite its own persistent memory between runs, so it improves at test time- no fine-tuning, no retraining. Huawei shipped a self-evolving memory engine on 1 July; EvolveMem beat the strongest baseline by 25.7% on LoCoMo; ICLR gave it a workshop. Sleep-time consolidation reaches the same accuracy with ~5x less compute.

In this lab you take a plain agent harness and make it self-evolving, from primitives:
- Extract → store → retrieve: the persistent memory base
- The evolve step: turn a failed run into a lesson the agent recalls next time
- A live checkpoint: your agent fails a task, consolidates what went wrong, and passes on the retry
- The failure mode, watch it mislearn: reinforce a bad heuristic, drift sycophantic
- The guardrails that make it converge instead of rot

Leave with a self-evolving agent harness you can drop into your own stack. The talk would be harness agnostic- can adapt it for any of the personal harness to make sure every user is adapting their workflow into a self evolving one
