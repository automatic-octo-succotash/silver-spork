# silver-spork

Minimal PostgreSQL migrations repository for the logistics data aggregation MVP. This repository is intentionally limited to the database migrations layer and is compatible with [`golang-migrate`](https://github.com/golang-migrate/migrate).

## Scope

- PostgreSQL only
- Raw SQL migrations only
- No application code
- No ORM, query builder, or schema DSL

Current source coverage:

- `crm` schema for RD Station CRM v2 ingestion and normalized entities
- `derived` schema for cross-entity analytics surfaces

## Repository Layout

```text
.
├── .dockerignore
├── .github/workflows/publish-image.yml
├── Dockerfile
├── Makefile
├── README.md
└── migrations
    ├── 0001_init.up.sql
    ├── 0001_init.down.sql
    ├── 0002_crm_raw.up.sql
    ├── 0002_crm_raw.down.sql
    ├── 0003_crm_normalized.up.sql
    ├── 0003_crm_normalized.down.sql
    ├── 0004_crm_sync_log.up.sql
    ├── 0004_crm_sync_log.down.sql
    ├── 0005_derived_deal_metrics.up.sql
    ├── 0005_derived_deal_metrics.down.sql
    ├── 0006_crm_oauth.up.sql
    └── 0006_crm_oauth.down.sql
```

## Running Migrations

Install [`golang-migrate`](https://github.com/golang-migrate/migrate/tree/master/cmd/migrate) and point it at a PostgreSQL database.

With `migrate` directly:

```bash
migrate -path ./migrations -database "$DATABASE_URL" up
migrate -path ./migrations -database "$DATABASE_URL" down 1
```

Or via the included `Makefile`:

```bash
export DATABASE_URL='postgres://user:password@localhost:5432/silver_spork?sslmode=disable'
make migrate-up
make migrate-down STEPS=1
```

## Container Image

This repo also publishes a Docker image to GHCR for use by a separate infra repository later. The image contains only:

- the `migrate` CLI binary
- the baked SQL files at `/migrations`

Build locally:

```bash
docker build -t silver-spork-migrations .
```

Run locally against PostgreSQL:

```bash
export DATABASE_URL='postgres://user:password@host.docker.internal:5432/silver_spork?sslmode=disable'
docker run --rm \
  -e DATABASE_URL="$DATABASE_URL" \
  silver-spork-migrations \
  sh -lc 'migrate -path /migrations -database "$DATABASE_URL" up'
```

Use a database hostname that is reachable from the container runtime in your environment.

The image defaults to `migrate -help`, so an infra repo can override the command for an init container or one-off Job without needing a wrapper script.

## GHCR Publishing

GitHub Actions builds and publishes `ghcr.io/<owner>/<repo>` from this repository:

- pushes to `main` publish `latest`
- every publish also gets an immutable commit SHA tag
- pushed Git tags matching `v*` also publish that version tag

This repository only produces the reusable migration artifact. A future infra repository can pull that image and decide when and how to execute the migrations.

## Schema Philosophy

`crm.raw_*`

- Stores source payloads as fetched from RD Station CRM v2.
- Preserves the original API response in `JSONB`.
- Includes only minimal extracted fields needed for operational filtering and indexing.
- Keeps the `crm.raw_deal_products` identifier assumption explicit and provisional until validated against live payloads from `GET /crm/v2/deals/{deal_id}/products`.
- Supports replayable ETL and re-normalization without re-fetching historical source data.

`crm.*`

- Stores the normalized, queryable CRM model.
- Uses explicit foreign keys and indexes so downstream API and ETL jobs can depend on stable relational contracts.
- Keeps `crm.deals.owner_id` nullable so ETL is not brittle when owner assignment is missing or temporarily inconsistent during ingestion.
- Enforces pipeline/stage consistency relationally so a deal cannot reference a stage from a different pipeline.
- Is intended to be populated by idempotent upserts keyed on source identifiers.

`derived.*`

- Stores read-oriented analytical surfaces that may join or reshape normalized data across sources.
- Starts with `derived.deal_metrics`, implemented as a materialized view because this repository owns schema only, not refresh orchestration.
- Keeps only stable base facts and status-derived flags; dashboard windows such as current month and rolling 12 months should be computed at query or API time instead of being materialized as aging booleans.
- The ETL or job runner is expected to refresh derived objects after normalized loads complete.

## ETL Expectations

Normalized tables are designed for idempotent ETL:

- load source payloads into `crm.raw_*`
- transform and upsert into `crm.*` using source IDs as stable keys
- refresh `derived.deal_metrics`

Normalized deal loads should tolerate missing owners and should only write `(stage_id, pipeline_id)` pairs that exist in `crm.pipeline_stages`.

Typical loading order:

1. `crm.raw_pipelines`
2. `crm.raw_pipeline_stages`
3. `crm.raw_users`
4. `crm.raw_products`
5. `crm.raw_deals`
6. `crm.raw_deal_products`
7. normalized upserts into `crm.*`
8. refresh `derived.deal_metrics`

Before the ETL worker can perform its first OAuth token rotation for RD Station CRM v2, `crm.oauth_state` must be seeded manually with the initial `access_token`, `refresh_token`, and an `expires_at` timestamp.

## Notes

- All timestamps use `TIMESTAMPTZ`.
- All migrations are reversible.
- The schema naming pattern is source-oriented so additional schemas such as `wms`, `tms`, and `erp` can be added later without reshaping the current CRM namespace.
