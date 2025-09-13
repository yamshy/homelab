# Graphiti MCP Server

Deploys the Graphiti Model Context Protocol (MCP) server backed by Neo4j. The service exposes an SSE endpoint at `/sse` for real-time responses.

## Access

- **Ingress**: `https://graphiti.${SECRET_TAILNET}`
- **SSE Endpoint**: `https://graphiti.${SECRET_TAILNET}/sse`

## Client Configuration

Configure MCP clients to connect to the SSE endpoint and authenticate using the `OPENAI_API_KEY` stored in the `graphiti-env` secret.
