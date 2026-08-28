# Go / Runtime Internals Reference

Working notes for problems that probe what's actually happening underneath Go backend code — the layer between "I wrote a function" and "the CPU executed instructions."

## Stack vs. heap, and escape analysis

Every goroutine gets its own stack (starts small, ~8KB, grows/shrinks as needed via copying — not a fixed-size overflow risk the way OS thread stacks can be). The compiler decides at compile time, via **escape analysis**, whether a value can live on the stack (fast: no GC involvement, freed automatically when the frame returns) or must "escape" to the heap (slower: GC-managed). A value escapes when its lifetime can outlive the function that created it — returned by pointer, captured by a closure that outlives the call, stored in an interface, or its size/type isn't knowable at compile time. `go build -gcflags="-m"` prints these decisions; this is the actual tool to reach for, not guessing.

The interview-relevant consequence: passing a large struct by pointer to "avoid copying" can *cause* a heap escape that wouldn't have happened if you passed by value and let it stay on the stack — "pointers are always faster" is a C mental model that doesn't transfer directly to Go.

## Goroutines and the scheduler

A goroutine is a user-space, cooperatively-and-preemptively-scheduled unit of work, not an OS thread — thousands to millions can exist because they're cheap (small starting stack, scheduled by Go's runtime, not the kernel). The scheduler uses the **G-M-P model**: G (goroutine), M (OS thread, "machine"), P (processor — a scheduling context, count defaults to `GOMAXPROCS`, roughly CPU cores). A P must hold an M to run G's; when a G blocks on a syscall, its M can be handed off so the P keeps running other G's on a different M — this is why blocking syscalls don't stall the whole scheduler, but do still cost an extra OS thread.

Since Go 1.14, the scheduler is **asynchronously preemptible** — a goroutine in a long-running tight loop with no function calls can still be preempted (earlier versions could starve other goroutines in that case; this is a real "which Go version" interview distinction).

## Channels and the memory model

A channel is a typed, synchronized queue: send/receive on an unbuffered channel *rendezvous* (both sides block until the other is ready — this is a synchronization point, not just data transfer). A buffered channel decouples sender and receiver up to the buffer size, then blocks the same way once full/empty.

The Go memory model's guarantee that actually matters in interviews: a send on a channel happens-before the corresponding receive completes. This is what makes "goroutine A sends work on a channel, goroutine B receives and reads the result" *safe without a separate mutex* — the channel operation itself is the synchronization. Sharing memory by communicating (channels) vs. communicating by sharing memory (mutex + shared variable) are both valid; channels are usually the right default for coordination/handoff, mutexes for protecting a small piece of shared state accessed from many places.

## Concurrency primitives and races

`sync.Mutex` / `sync.RWMutex` protect shared state; `RWMutex` allows concurrent readers but is not automatically a win — under high write contention or very short critical sections, the extra bookkeeping can make it *slower* than a plain `Mutex`, so it's a measure-don't-assume choice.

**Atomics** (`sync/atomic`) do lock-free reads/writes of a single word (int32/64, pointer) using CPU-level compare-and-swap — cheaper than a mutex for simple counters/flags, but do not compose: incrementing two related atomics is not atomic *together*, and reaching for atomics to protect a multi-field invariant is a common bug source.

**Race conditions** in Go are UB-adjacent in practice: the race detector (`go test -race`, `go run -race`) instruments memory accesses and catches many real races at runtime, but it only catches races that actually execute during that run — it is not a proof of absence, only evidence.

**Deadlock vs. starvation:** deadlock is a cycle of goroutines each waiting on a resource the next one holds (classic: two mutexes locked in inconsistent order across two goroutines) — Go's runtime detects a *global* deadlock (all goroutines asleep) and panics, but will *not* detect a deadlock among a subset of goroutines while others remain runnable. Starvation is a goroutine that's technically unblocked but never actually gets scheduled/gets the lock because others keep winning the race for it — much harder to detect, usually shows up as a latency-tail problem, not a hang.

## Garbage collection and write barriers

Go's GC is concurrent, tri-color mark-and-sweep with a goal of sub-millisecond STW (stop-the-world) pauses — the actual pause today is largely limited to the mark-start and mark-end phases, not the whole mark phase. Because marking happens *concurrently* with the mutator (your running program), a **write barrier** is required: when the mutator writes a pointer into an already-marked (black) object, pointing at an unmarked (white) object, the write barrier ensures that white object gets marked too — otherwise the GC could "lose" a live object that was only reachable through a pointer written after that region was already scanned (the classic concurrent-GC correctness bug). This is why write barriers exist and why they impose real (small but nonzero) overhead on every pointer write during a GC cycle.

`GOGC` (target heap growth ratio before next GC) and `GOMEMLIMIT` (a soft memory cap, added more recently) are the two levers for GC tuning — the interview-relevant nuance is that `GOGC` trades memory for CPU (higher GOGC = fewer, larger GC cycles = less CPU spent collecting, more RAM held), and `GOMEMLIMIT` is what you reach for when you have a hard memory ceiling (container limit) rather than a CPU concern.

## Practical Go-in-production notes

- **Escape-driven allocation churn** is a common, unglamorous perf bottleneck: a hot path that allocates on every call (e.g. `fmt.Sprintf` in a tight loop, appending to a slice without pre-sized capacity) pushes GC to run more often — `pprof`'s heap/allocs profile, not intuition, is how you actually find this.
- **Connection pooling** (`database/sql`'s built-in pool, or an HTTP client's `Transport`) defaults matter: an unbounded or misconfigured `MaxOpenConns` can let a traffic spike open enough DB connections to take the database down; an HTTP client reused without `MaxIdleConnsPerHost` tuned can end up re-dialing/re-handshaking far more than expected under concurrent load.
- **Context cancellation** (`context.Context`) is Go's mechanism for propagating "give up" (timeout, explicit cancel, parent canceled) down a call chain — the common bug is a function that accepts a `ctx` but never actually checks `ctx.Done()` or passes it into the blocking call it makes, silently ignoring the cancellation contract.
