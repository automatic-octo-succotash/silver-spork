BEGIN;

-- Normalized tables expose a stable relational contract for API and ETL layers.
-- Loads should use idempotent upserts keyed by source IDs instead of append-only inserts.

CREATE TABLE crm.pipelines (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL
);

COMMENT ON TABLE crm.pipelines IS 'Normalized RD Station pipelines.';

CREATE TABLE crm.users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    is_active BOOLEAN NOT NULL
);

COMMENT ON TABLE crm.users IS 'Normalized RD Station users, typically deal owners.';

CREATE TABLE crm.products (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL
);

COMMENT ON TABLE crm.products IS 'Normalized RD Station products.';

CREATE TABLE crm.pipeline_stages (
    id TEXT PRIMARY KEY,
    pipeline_id TEXT NOT NULL,
    name TEXT NOT NULL,
    position INTEGER NOT NULL,
    CONSTRAINT pipeline_stages_pipeline_id_fkey
        FOREIGN KEY (pipeline_id)
        REFERENCES crm.pipelines (id)
        ON DELETE RESTRICT
);

COMMENT ON TABLE crm.pipeline_stages IS 'Normalized RD Station pipeline stages scoped to a pipeline.';

CREATE INDEX pipeline_stages_pipeline_id_idx ON crm.pipeline_stages (pipeline_id);
CREATE INDEX pipeline_stages_pipeline_id_position_idx ON crm.pipeline_stages (pipeline_id, position);

CREATE TABLE crm.deals (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    status TEXT NOT NULL,
    pipeline_id TEXT NOT NULL,
    stage_id TEXT NOT NULL,
    owner_id TEXT NOT NULL,
    won_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    amount NUMERIC(18,2),
    CONSTRAINT deals_pipeline_id_fkey
        FOREIGN KEY (pipeline_id)
        REFERENCES crm.pipelines (id)
        ON DELETE RESTRICT,
    CONSTRAINT deals_stage_id_fkey
        FOREIGN KEY (stage_id)
        REFERENCES crm.pipeline_stages (id)
        ON DELETE RESTRICT,
    CONSTRAINT deals_owner_id_fkey
        FOREIGN KEY (owner_id)
        REFERENCES crm.users (id)
        ON DELETE RESTRICT
);

COMMENT ON TABLE crm.deals IS 'Normalized RD Station deals for operational querying and downstream analytics.';

CREATE INDEX deals_status_idx ON crm.deals (status);
CREATE INDEX deals_won_at_idx ON crm.deals (won_at);
CREATE INDEX deals_pipeline_id_idx ON crm.deals (pipeline_id);
CREATE INDEX deals_stage_id_idx ON crm.deals (stage_id);
CREATE INDEX deals_owner_id_idx ON crm.deals (owner_id);
CREATE INDEX deals_pipeline_stage_idx ON crm.deals (pipeline_id, stage_id);
CREATE INDEX deals_updated_at_idx ON crm.deals (updated_at);

CREATE TABLE crm.deal_products (
    deal_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    quantity NUMERIC(18,4),
    amount NUMERIC(18,2),
    PRIMARY KEY (deal_id, product_id),
    CONSTRAINT deal_products_deal_id_fkey
        FOREIGN KEY (deal_id)
        REFERENCES crm.deals (id)
        ON DELETE RESTRICT,
    CONSTRAINT deal_products_product_id_fkey
        FOREIGN KEY (product_id)
        REFERENCES crm.products (id)
        ON DELETE RESTRICT
);

COMMENT ON TABLE crm.deal_products IS 'Normalized many-to-many association between deals and products.';

CREATE INDEX deal_products_deal_id_idx ON crm.deal_products (deal_id);
CREATE INDEX deal_products_product_id_idx ON crm.deal_products (product_id);

COMMIT;
