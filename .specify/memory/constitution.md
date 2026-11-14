<!--
Sync Impact Report
- Version change: 1.0.0 → 2.0.0 (MAJOR: new workspace dependency edge a2a → mcp, which
  Governance classes as MAJOR)
- Modified principles (titles unchanged):
  - I. Clarity Over Cleverness: a test fake now counts as a concrete use for the two-uses rule
  - V. One-Way Package Dependencies: `a2a` MAY now depend on `mcp`; graph MUST stay acyclic;
    rationale updated
- Modified sections:
  - Development Workflow & Quality Gates: Principle IV gates MUST pass locally and in CI
    (.github/workflows/ci.yml); a change is not done while CI is red
- Added sections: none
- Removed sections: none
- Templates: dependent templates read this file at runtime; none modified by this amendment
- Follow-up (outside this file): README.md "Layout" still says `a2a` depends on `harness` only;
  packages/a2a/pyproject.toml does not yet declare `agent-stack-mcp`
- Deferred TODOs: none
-->

# agent-stack Constitution

## Core Principles

### I. Clarity Over Cleverness

agent-stack is a learning project. Code exists to be read and understood first.

- Code MUST favour explicit, readable constructs over terse or "clever" ones (deep metaprogramming,
  dense comprehensions, implicit magic). When a clever form is materially better, it MUST carry a
  comment explaining what it does and why.
- Names MUST describe intent. Modules SHOULD be small and single-purpose.
- New abstractions MUST be justified by at least two concrete uses; speculative generality is
  rejected (YAGNI). A test fake counts as a concrete use, so an interface with one real
  implementation plus a fake used in tests (for example, the Bedrock provider interface)
  satisfies this rule.
- Non-obvious protocol or design decisions MUST be documented next to the code or in the
  feature's spec/plan, so a reader can learn *why*, not only *what*.

Rationale: the goal is understanding how agents, MCP and A2A work. Opaque code defeats that goal
even when it works.

### II. Harness From Scratch (No Agent Frameworks)

The agent harness (`packages/harness`, `agent_stack_harness`) is written from first principles.

- The workspace MUST NOT depend on agent or orchestration frameworks (for example LangChain,
  LangGraph, LlamaIndex, CrewAI, AutoGen, Strands Agents, Bedrock Agents, or agent SDKs that run
  the model/tool loop for you).
- The model call loop, tool dispatch, message history and stop conditions MUST be implemented in
  this repository.
- Permitted: the Amazon Bedrock runtime client (`boto3`), the official protocol SDKs (`mcp`,
  `mcp-types`, `a2a-sdk`) inside the packages that implement those protocols, and general-purpose
  libraries (HTTP, validation, serialization, testing).

Rationale: building the loop yourself is the point of the exercise; a framework would hide exactly
the parts being learned.

### III. Pinned Protocol Targets

Each protocol has exactly one supported version.

- MCP code MUST target spec revision **2026-07-28** only. It is stateless: there MUST be no
  `initialize` handshake, no session IDs, and no compatibility shims for earlier revisions.
- A2A code MUST target protocol **v1.0.x** only, via `a2a-sdk` 1.x. The `a2a.compat.v0_3` module
  and any pre-1.0 behaviour MUST NOT be used.
- Material that predates these versions (tutorials, examples, generated suggestions) MUST be
  checked against the pinned spec before it is applied.
- Changing a protocol target is a constitution amendment (see Governance).

Rationale: supporting several versions multiplies complexity and muddles what is being learned.

### IV. Typed, Linted, Tested (NON-NEGOTIABLE)

- `uv run pyright` (strict mode), `uv run ruff check`, `uv run ruff format --check` and
  `uv run pytest` MUST all pass before any change is considered done.
- Every feature MUST ship with tests that exercise its behaviour; a feature without tests is not
  complete.
- Type-checker or linter suppressions (`# type: ignore`, `# pyright: ignore`, `# noqa`) MUST name
  the specific rule and carry a short reason.
- The default test run MUST be offline and deterministic: Bedrock and other network services are
  replaced with fakes or recorded fixtures. Tests that call live AWS MUST be opt-in behind an
  explicit pytest marker.
- Protocol-facing code (MCP server/client, A2A agent/orchestrator) MUST have contract tests that
  check messages against the pinned spec shapes.

Rationale: strict types and tests make the code trustworthy enough to learn from and to change.

### V. One-Way Package Dependencies

Workspace packages form a directed acyclic graph that MUST NOT gain new edges without an
amendment:

- `harness` (`agent_stack_harness`) depends on nothing in the workspace.
- `knowledge-graph` (`agent_stack_kg`) depends on nothing in the workspace.
- `mcp` (`agent_stack_mcp`) MAY depend on `harness` and `knowledge-graph`.
- `a2a` (`agent_stack_a2a`) MAY depend on `harness` and `mcp`.
- The dependency graph MUST stay acyclic: no package may depend, directly or transitively, on a
  package that depends on it.

Further rules:

- Import names MUST keep the `agent_stack_` prefix so they never shadow the `mcp` or `a2a` SDKs.
- Each package MUST use the `src/` layout and ship `py.typed`.
- Integration points (for example, the harness consuming MCP tools) MUST be expressed as
  interfaces owned by the lower package and implemented by the higher one.

Rationale: a one-way graph keeps each package understandable and testable on its own. The
`a2a` → `mcp` edge exists because the A2A agent wraps a harness that reaches the knowledge graph
through the MCP client adapter; it points from the last-built package to an earlier one, so the
graph stays acyclic.

## Technology & Platform Constraints

- **Language & tooling**: Python 3.15 in a uv workspace (`packages/*`). Tool versions are pinned in
  `pyproject.toml` and the README; upgrades are deliberate changes, not side effects.
- **LLM provider**: Amazon Bedrock is the only model provider. Model access MUST go through a
  small, typed provider interface in the harness so tests can substitute a fake.
- **Infrastructure**: all cloud resources MUST be defined in Terraform under `infra/terraform`,
  targeting AWS. Resources MUST NOT be created by hand in the console. `terraform fmt -check` and
  `terraform validate` MUST pass for infrastructure changes.
- **Secrets**: credentials and secrets MUST NOT be committed. Local values live in
  `terraform.tfvars` (git-ignored) or the environment.
- **Build order**: packages are built in order: harness → knowledge graph → MCP server and client
  adapter → A2A agent and demo orchestrator. A package's features MUST NOT depend on a later
  package's unfinished work.

## Development Workflow & Quality Gates

- Work proceeds through Spec Kit: specify → (clarify) → plan → tasks → implement. Each plan MUST
  include a Constitution Check against Principles I–V and record any justified exception in its
  Complexity Tracking section.
- A change is complete only when all Principle IV gates pass both locally from a clean `uv sync`
  and in CI (`.github/workflows/ci.yml`). A change is not done while CI is red.
- Runtime dependencies are added to the specific package that needs them
  (`uv add --package <name> ...`), never to the workspace root.
- Commits SHOULD be small and focused on one change, with messages that explain the reason.

## Governance

- This constitution takes precedence over other conventions in the repository. When a document
  or tutorial conflicts with it, the constitution wins.
- Amendments are made by editing this file (normally via `/speckit-constitution`), with a Sync
  Impact Report, a version bump and an updated Last Amended date.
- Versioning follows semantic versioning:
  - MAJOR: a principle is removed or redefined incompatibly, a protocol target changes, or a new
    dependency edge is allowed between packages.
  - MINOR: a principle or section is added or materially expanded.
  - PATCH: clarifications and wording fixes that do not change meaning.
- Compliance is checked at plan time (Constitution Check) and again before a feature is marked
  complete. Unjustified violations block the feature.
- Runtime development guidance (commands, pinned versions, layout) lives in `README.md`.

**Version**: 2.0.0 | **Ratified**: 2026-11-14 | **Last Amended**: 2026-11-14
