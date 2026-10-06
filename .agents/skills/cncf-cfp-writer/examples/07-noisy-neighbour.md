# Noisy Neighbour: An SRE Field Guide to LLM Inference

"Noisy neighbour" used to mean a container stealing CPU. Inside an LLM server, the neighbour is sitting on the same GPU, in the same batch, on the same iteration as you. Servers like vLLM and TGI use continuous batching - your request is fused onto the GPU alongside strangers', decoded token by token, in a batch that reshuffles every step. So when your p99 spikes, it's often not a slow request at all. It's a batch-mate generating 4,000 tokens, or the KV cache thrashing and preempting you. Your per-request trace can't see any of it.

This is an SRE's field guide to observing LLM inference honestly. We'll cover why classic RED and latency dashboards mislead you here, and the signals that actually matter: time-to-first-token vs inter-token latency, KV cache utilization and prefix-cache hit rate, queue depth, and batch occupancy. Using DCGM, Prometheus, and inference-server metrics, we'll trace a real serving stack and pin a latency spike on its true cause - scheduling, memory, or that neighbour.

You'll leave able to debug what dashboards can't tell you today: whose request is actually slow, and why?
