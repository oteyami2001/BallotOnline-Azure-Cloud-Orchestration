# Architecture Decision Records

Architecture Decision Records (ADRs) document the important technical
decisions made in the BallotOnline cloud architecture project — not just
how the environment was built, but **why** each approach was chosen.

Each ADR records:

1. **Context** — the problem and constraints
2. **Decision** — what was chosen
3. **Alternatives** — what else was considered
4. **Rationale** — why this option won
5. **Consequences** — the trade-offs accepted

## Decisions

| ADR | Decision | Status |
|---|---|---|
| [ADR-001](ADR-001-iaas-vs-paas.md) | Evaluate Azure App Service (PaaS) alongside VM-based IaaS | Accepted |
| [ADR-002](ADR-002-load-balanced-vmss.md) | Use a VM Scale Set behind Azure Load Balancer | Accepted |

## Adding an ADR

Copy an existing record, give it the next number (`ADR-003-<short-title>.md`),
and add it to the table above. ADRs are not edited after acceptance; a
changed decision gets a new ADR that supersedes the old one.
