# A2A + MCP: Building Self-Orchestrating Multi-Agent Workflows on AWS Serverless

Give a single AI agent 30+ tools and watch its accuracy drop to 48%. The answer isn't a smarter model- it's specialized agents that coordinate.

Multiagent systems is where things get real.

This session combines two open protocols- Google's Agent-to-Agent (A2A) for inter-agent communication and Anthropic's Model Context Protocol (MCP) for tool access to build multi-agent workflows on AWS serverless.

We'll build a system where specialized agents discover each other via A2A, invoke tools through MCP servers, and orchestrate on Lambda, Step Functions, and Bedrock. No long-running servers.

What we'll cover:
- Deploying MCP servers on Lambda and zero-code via AgentCore Gateway
- A2A agent discovery and task delegation
- Step Functions for parallel agent invocation with retries and timeouts
- Strands Agents SDK; open source by AWS
- Sharp edges: cold start compounding, tool selection accuracy, context window limits
- When multi-agent makes sense vs when a single agent is enough

Includes a live demo, protocols, architecture, and code.
