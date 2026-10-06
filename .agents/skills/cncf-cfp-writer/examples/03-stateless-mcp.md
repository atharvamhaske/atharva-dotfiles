# Stateless MCP: Inside the 2026 Transport Spec

Most MCP servers in production today are stateful- each client session is pinned to one server instance.

That works on a single node. Add a load balancer and scale horizontally, and sessions start breaking: Kubernetes routes a request to the wrong pod, a Fargate deployment rolls and drops active connections, and NGINX or AWS ALB need special configuration just to keep the server reachable.

The 2026 spec release candidate, locked May 21, fixes this at the transport layer through three SEPs.
- SEP-1442 removes the mandatory init handshake so negotiation folds into the first request.
- SEP-2322 makes elicitation stateless.
- SEP-2243 mirrors routing data into HTTP headers so load balancers can route without parsing the payload.

This session covers what each SEP changes, what breaks in the server you run today, and what to refactor before the spec ships. I'll also show how we externalize session state at Mem0, so a stateless server keeps the memory and context a real agent needs.

You'll leave with a migration checklist and an architecture for stateless-first MCP.
