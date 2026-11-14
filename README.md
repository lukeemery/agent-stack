# agent-stack

A learning monorepo that builds, in order:

1. **`packages/harness`** (`agent_stack_harness`): an agent harness written from scratch, with no agent frameworks.
2. **`packages/knowledge-graph`** (`agent_stack_kg`): a supply-chain knowledge graph (parts, suppliers, assemblies, lead times).
3. **`packages/mcp`** (`agent_stack_mcp`): an MCP server exposing the knowledge graph, plus an MCP client adapter for the harness.
4. **`packages/a2a`** (`agent_stack_a2a`): an A2A agent wrapping the harness, plus a demo orchestrator that delegates to it.

Infrastructure (AWS) lives in `infra/terraform`.

## Protocol targets

- **MCP:** spec revision **2026-07-28**. It is stateless: no `initialize` handshake and no session IDs. Ignore tutorials that predate it.
- **A2A:** protocol **v1.0.x**, using `a2a-sdk` 1.x. Don't use the `a2a.compat.v0_3` module.

## Pinned versions

| Tool | Version |
| --- | --- |
| uv | 0.13.8 (minimum, enforced via `tool.uv.required-version`) |
| Python | 3.15 (`.python-version`) |
| mcp / mcp-types | 2.3.0 |
| a2a-sdk | 1.3.0 |
| ruff / pyright / pytest | 0.17.5 / 1.1.414 / 9.2.0 |
| Terraform / AWS provider | 1.17.2 / ~> 6.73 |
| Spec Kit (`specify-cli`) | 1.4.0 |

## Development

```bash
uv sync                    # create .venv with all workspace packages + dev tools
uv run ruff check          # lint
uv run ruff format         # format
uv run pyright             # type-check (strict)
uv run pytest              # tests
```

Add a runtime dependency to one package:

```bash
uv add --package agent-stack-harness <dependency>
```

Terraform:

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
terraform init -backend=false
terraform validate
```

## Layout

Each package uses a `src/` layout and ships `py.typed`. Import names are prefixed `agent_stack_` so they never shadow the `mcp` or `a2a` SDK packages. Dependencies point one way: `harness` and `kg` depend on nothing in the workspace; `mcp` depends on both; `a2a` depends on `harness` and `mcp`.
