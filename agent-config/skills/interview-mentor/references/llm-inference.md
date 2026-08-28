# LLM Inference Engineering Reference

Working notes on serving LLMs in production — the stack between "here's a model checkpoint" and "here's an API endpoint that answers in 200ms." Grounded in the Modular LLM inference handbook (handbook.modular.com) and current (2026) vLLM/KServe/Envoy AI Gateway material. Useful for Day A (mechanics) and Day B (serving-system design) problems.

## The metrics that actually define "fast"

- **TTFT (time to first token):** latency from request received to the first output token — dominated by the *prefill* phase (processing the entire input prompt through the model in one forward pass before any generation starts). A long input prompt directly costs TTFT even before generation begins.
- **Inter-token latency / tokens-per-second:** how fast tokens stream out after the first one — dominated by the *decode* phase, which (unlike prefill) is memory-bandwidth-bound, not compute-bound, because each decode step only processes one new token but must read the entire growing KV cache.
- **Goodput vs. throughput:** raw throughput (tokens/sec across all requests) can look great while individual requests blow past their latency SLO — goodput is throughput *of requests that met their target*, which is the number that actually reflects whether the service is doing its job. A system can improve raw throughput while goodput gets worse if it does so by making individual requests wait longer in queue.

## Prefill vs. decode, and why disaggregating them is a real technique

Prefill is compute-bound (parallel over the whole prompt, GPU-saturating) and decode is memory-bandwidth-bound (one token at a time, GPU mostly idle waiting on KV-cache reads) — running both on the same GPU workers means decode requests get stuck behind prefill's compute-heavy bursts, hurting inter-token latency predictability. **Prefill-decode disaggregation** runs prefill and decode on separate pools of workers (sized differently, since their bottlenecks differ), handing off the KV cache from a prefill worker to a decode worker once the prompt's been processed — this is an active area of 2026 serving-stack design specifically because it lets each phase be scaled and scheduled according to its own bottleneck instead of a one-size-fits-all worker pool.

## KV cache: the central resource being managed

Each attention layer caches the key/value tensors for every token already generated, so decode doesn't need to recompute attention over the whole sequence from scratch every step — this cache grows linearly with sequence length and is usually the actual memory bottleneck for serving, not the model weights themselves once context windows get long or concurrency gets high.

- **Paged attention** (vLLM's foundational technique) manages the KV cache in fixed-size non-contiguous blocks, the way an OS manages virtual memory pages, instead of requiring one large contiguous allocation per sequence — this eliminates the memory fragmentation that made naive KV-cache allocation waste a large fraction of GPU memory before paged attention existed.
- **Prefix caching** reuses the KV cache for a shared prompt prefix across multiple requests (e.g. a common system prompt, or repeated few-shot examples) instead of recomputing it every time — a request-routing decision that's *aware* of which workers already have a given prefix cached (prefix-cache-aware routing) can dramatically cut redundant prefill work at the gateway/router layer, which is exactly what recent inference gateways optimize for.
- **Hierarchical KV offloading** spills colder KV cache entries out of GPU HBM to CPU RAM or even disk when GPU memory is under pressure, trading some latency on cache-miss for supporting more concurrent long-context sessions than would otherwise fit.

## Batching strategies

- **Static batching:** fixed batch assembled up front, all requests must finish before the batch returns — simple, but one long request holds the whole batch hostage and short requests wait needlessly.
- **Dynamic batching:** batches assembled per-iteration from whatever's queued, but still typically waits for the whole batch to complete a step together.
- **Continuous batching** (a.k.a. iteration-level scheduling): the technique that made modern high-throughput serving practical — at every decode step, the scheduler can add newly arrived requests and evict/return completed ones, without waiting for the whole batch to finish. This is the single biggest lever for GPU utilization in production LLM serving, because it keeps the GPU fed even though different requests finish at different token counts.
- **Speculative decoding:** a small, fast "draft" model proposes several tokens ahead, and the large model verifies them in a single batched forward pass, accepting the ones that match what it would have generated itself — a throughput optimization that trades extra draft-model compute for fewer large-model forward passes per accepted token, useful when generation is memory-bandwidth-bound (which it usually is) rather than compute-bound.

## The three-layer serving stack (vLLM / KServe / Envoy AI Gateway)

A production LLM serving stack in 2026 is commonly organized in three layers, each solving a different problem:

1. **Inference engine (vLLM)** — the actual model-execution layer: paged attention, continuous batching, speculative decoding, quantized/parallel execution. This is a single-process (or single-node, for large models needing multi-GPU sharding) engine focused purely on maximizing tokens-per-second-per-GPU.
2. **Serving/orchestration layer (KServe)** — wraps one or many vLLM instances into a distributed model-serving system: autoscaling (including scale-to-zero for cost), failover, and — via a purpose-built custom resource for LLM workloads — support for splitting very large models across multiple GPUs (tensor parallelism, pipeline parallelism) so a 70B+ parameter model can be served at all. This layer answers "how many replicas, how do they come up/down, how does a large model get sharded."
3. **Gateway/routing layer (Envoy AI Gateway)** — the stable external entry point in front of potentially many models/pools: token-aware rate limiting (rate-limiting by token count, not just request count, since token cost varies wildly per request), dynamic model routing, multi-tenant auth, usage tracking, and — critically — prefix-cache-aware routing, sending a request to whichever backend worker already has its prompt prefix cached rather than routing blindly (e.g. round robin), which directly improves effective KV-cache hit rate cluster-wide.

The interview-useful mental model: **vLLM answers "how fast is one GPU," KServe answers "how do many GPUs/replicas behave as a fleet," Envoy AI Gateway answers "how does traffic get to the right place in that fleet efficiently."** A question like "your inference cluster's GPU utilization looks fine but p99 latency is bad" almost always traces to the gateway/routing layer (poor cache-aware routing, or a hot model getting more traffic than its replica count can absorb) rather than the engine layer.

## Quantization and hardware trade-offs

Reducing numeric precision (FP16 → INT8 → INT4, etc.) shrinks both the memory footprint of weights and the KV cache, and can speed up compute-bound operations — at some cost to output quality, which varies by technique and how aggressively you quantize. For a memory-bandwidth-bound decode phase, quantizing weights specifically helps because there's simply less data to move per token; the KV cache's own size (not just the weights) is often the actual reason a model can't fit more concurrent sessions in GPU memory, which is why some deployments quantize the KV cache separately from the model weights.

## Sources consulted while writing this file

- [Modular LLM Inference Handbook](https://handbook.modular.com/) — topic/terminology grounding (TTFT, continuous batching, prefix caching, KV cache, prefill-decode disaggregation, goodput, quantization).
- 2026 web search covering the vLLM/KServe/llm-d/Envoy AI Gateway serving stack and its layering, including [KServe's production-grade LLM inference post](https://kserve.github.io/website/blog/production-grade-llm-inference-kserve-llm-d-vllm) and [Envoy AI Gateway's reference architecture](https://aigateway.envoyproxy.io/blog/envoy-ai-gateway-reference-architecture/).
