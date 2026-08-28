# System Design Reference

Working notes for Day B (and some Day A/C) problems: distributed systems, caching, messaging, reliability, and observability fundamentals. Not a textbook — a source of accurate terminology and current framing to build problems from.

## Distributed systems core

**CAP** says that under a network partition, a system picks consistency or availability — it does not say you must always sacrifice one; most of the time there's no partition and you get both. The useful interview framing is PACELC: even *without* a partition (E), you still trade Latency for Consistency. That second trade-off is the one that shows up in everyday design decisions (sync replication vs async replication), while CAP itself only bites during an actual partition.

**Strong vs eventual consistency.** Strong consistency means every read sees the latest committed write, everywhere, immediately — expensive, usually requires consensus or a single writer. Eventual consistency means replicas converge *eventually* with no bound promised — cheap, available, but callers must tolerate stale reads. Read-your-writes, monotonic-reads, and bounded-staleness are the useful middle grounds interviewers expect you to know exist between the two extremes.

**Quorums.** For N replicas, a write quorum W and read quorum R with W + R > N guarantees every read overlaps at least one replica that saw the latest write. Classic tuning: W=1,R=N favors fast writes/slow reads; W=N,R=1 the reverse; W=R=(N/2)+1 balances both and tolerates minority failures. This is the mechanism under Dynamo-style stores (Cassandra, Riak) — know it cold, it's a frequent whiteboard ask.

**Consensus (Raft/Paxos), conceptually.** A cluster needs to agree on a single value (who's leader, what's committed next) even if some nodes crash or messages are lost, as long as a majority are up and can talk to each other. Raft's practical shape: a leader is elected by majority vote for a term; the leader appends log entries and only commits an entry once a majority of followers have replicated it; if the leader dies, a new election happens. The interview-relevant consequence: a write is only safe once it's on a majority of nodes, not just the leader — this is why "the leader ack'd it" is not the same as "it's durable."

**Leader election** underlies primary/replica databases, distributed locks, and job schedulers alike. The failure mode to always probe: what happens during a *split brain* — two nodes each believe they're leader (e.g. after a partition heals asymmetrically). Fencing tokens (a monotonically increasing number handed out with each leadership grant, checked by anything the leader writes to) are the standard defense, not just "add a timeout."

**Idempotency.** A retried request must produce the same effect as if it ran once. The standard mechanism is a client-generated idempotency key stored server-side with the result of the first execution; a repeat with the same key returns the stored result instead of re-executing. This matters most exactly where retries are unavoidable — payment processing, message delivery, at-least-once queues.

**Failure detection and clocks.** Distributed systems can't reliably distinguish "node is dead" from "node is slow" from "network is dropping packets" — a timeout is a guess, not a fact. This is why designs that assume synchronized clocks (e.g. "just check if my heartbeat is younger than the other node's") are fragile; logical clocks (Lamport, vector clocks) or lease-based mechanisms (a time-bound grant that must be renewed) are the standard fix when ordering or exclusivity actually matters.

## Caching

The five access patterns, and their failure characteristics:

- **Cache-aside (lazy loading):** app checks cache, on miss reads DB and populates cache. Simple, but every miss pays full DB latency and a cold cache means a thundering herd of misses.
- **Read-through:** the cache library itself owns the DB read on miss — same behavior as cache-aside, cleaner abstraction, less app-code duplication.
- **Write-through:** every write goes to cache and DB synchronously. Reads are always fresh; writes pay double latency.
- **Write-back (write-behind):** write hits cache only, and is flushed to DB asynchronously. Fast writes, but a cache crash before flush loses data — only acceptable when that loss is tolerable.
- **TTL-based invalidation:** simplest correctness model (staleness bounded by TTL), but you're intentionally serving wrong answers for up to TTL seconds after a write.

**Cache stampede / dog-piling:** many concurrent requests miss the same hot key at once (e.g. right after expiry) and all hit the DB simultaneously. Mitigations: request coalescing/single-flight (only one goroutine actually fetches, others wait on its result), early/probabilistic refresh before expiry, and jittered TTLs so keys don't expire in lockstep.

**Hot keys:** a single key (a celebrity's profile, a viral post) receives disproportionate traffic and can pin one shard's CPU/network even though the cluster overall has headroom. Fixes: client-side local caching of the hot key, key replication across multiple cache nodes with random selection, or splitting the key into sharded sub-keys that get merged on read.

**Cache consistency vs. the DB:** the classic race is write DB → invalidate cache, where a concurrent reader can repopulate the cache with the *stale* pre-write value between those two steps. The standard mitigation is a short-TTL safety net plus, for correctness-critical paths, invalidate-then-write or a versioned/CDC-driven invalidation rather than app-code-triggered deletes.

## Messaging (Kafka-shaped systems)

A **topic** is a named stream, split into **partitions** for parallelism; each partition is a strictly ordered, append-only log. Ordering is only guaranteed *within* a partition, never across partitions of a topic — this is the single most-tested fact in interviews, because it directly determines your partitioning key choice (e.g. partition by user ID if per-user ordering matters).

**Consumer groups** let multiple consumers split a topic's partitions among themselves, each partition owned by exactly one consumer in the group at a time. **Rebalancing** — reassigning partitions when a consumer joins/leaves/crashes — pauses consumption for the group during the rebalance window, which is why rebalance frequency/duration is a real production metric, not just an implementation detail.

**Delivery semantics:**
- *At-most-once:* commit offset before processing — a crash after commit but before processing finishes loses the message.
- *At-least-once:* commit offset after processing — a crash after processing but before commit causes reprocessing (duplicate). This is the default almost everyone should choose, paired with idempotent consumers.
- *Exactly-once:* requires either transactional writes spanning the read-offset-commit and the side-effect (Kafka transactions, or a DB write + offset commit in one transaction), or an idempotency key at the consumer. True exactly-once *delivery* across arbitrary systems is not generally achievable — what's achievable is exactly-once *effect*, via idempotency.

**Backpressure and DLQs:** when a consumer can't keep up, lag grows unboundedly unless something pushes back — either the producer slows (backpressure), or messages that repeatedly fail processing get routed to a dead-letter queue instead of blocking the partition forever. A stuck message with no DLQ is a classic head-of-line-blocking incident: the whole partition stalls behind one poison message.

## Reliability patterns

**Circuit breaker:** after a failure-rate threshold, stop calling a failing dependency for a cooldown window and fail fast instead — protects the caller from wasting resources on calls likely to fail, and protects the callee from being hammered while it's already struggling. Three states: closed (normal), open (failing fast), half-open (probing with limited traffic to see if recovery happened).

**Bulkheads:** isolate resource pools (thread pools, connection pools) per dependency so one slow/failing dependency can't exhaust resources needed to serve requests that don't even touch it — named for ship compartments that contain flooding.

**Load shedding vs. graceful degradation:** shedding drops excess requests outright (usually cheapest-to-reject-first, e.g. non-authenticated or low-priority traffic) to protect the system's ability to serve the rest. Degradation keeps serving everyone but with reduced functionality (e.g. skip the personalization service, serve a generic feed) — pick per-endpoint based on whether "no response" or "worse response" is the better failure mode for that feature.

**Retries with backoff:** naive immediate retries synchronize into further load spikes (retry storms) exactly when the dependency is already struggling. Exponential backoff with jitter spreads retries out in time; capping total retry attempts and total retry *budget* (not just per-request) prevents a struggling dependency from being retried into the ground by the whole fleet at once.

## Observability

**RED** (for request-driven services): Rate, Errors, Duration. **USE** (for resources): Utilization, Saturation, Errors. Different lenses for different things — RED for "is this service healthy from the outside," USE for "is this resource the bottleneck."

**SLI/SLO/SLA:** an SLI is a measured indicator (e.g. "% of requests under 300ms"), an SLO is the internal target for that indicator (e.g. "99.9% of requests under 300ms over 28 days"), an SLA is the *externally* promised, usually contractual version with consequences for breach. **Error budget** = 1 − SLO, spent by *any* unreliability (deploys, incidents, planned maintenance) — the standard organizational use is: burn rate above budget pace freezes risky changes until the budget recovers.

**Latency percentiles:** p50 (median) tells you the typical experience; p99 tells you what your *worst-served* 1% of users see, which at scale is a lot of real users, and is usually what's actually causing complaints. Averages hide tail latency almost completely — a service with p50=50ms and p99=5s has an average that looks fine and a real problem.

## Sources consulted while writing this file

- General distributed-systems and SRE fundamentals (Raft, CAP/PACELC, Kafka semantics, Google SRE error-budget framing) — standard, stable material, not fetched from a single live source for this pass.
