BEGIN;

-- Raw tables preserve source payloads exactly as fetched. Downstream ETL is
-- expected to be idempotent and re-runnable from these source-of-truth payloads.

CREATE TABLE crm.raw_deals (
    id TEXT PRIMARY KEY,
    payload JSONB NOT NULL,
    synced_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ,
    status TEXT,
    pipeline_id TEXT,
    stage_id TEXT,
    owner_id TEXT
);

COMMENT ON TABLE crm.raw_deals IS 'Raw RD Station deals payloads plus minimal extracted fields for operational filters.';

CREATE INDEX raw_deals_payload_gin_idx ON crm.raw_deals USING GIN (payload);
CREATE INDEX raw_deals_status_idx ON crm.raw_deals (status);
CREATE INDEX raw_deals_pipeline_id_idx ON crm.raw_deals (pipeline_id);
CREATE INDEX raw_deals_stage_id_idx ON crm.raw_deals (stage_id);
CREATE INDEX raw_deals_owner_id_idx ON crm.raw_deals (owner_id);
CREATE INDEX raw_deals_updated_at_idx ON crm.raw_deals (updated_at);

CREATE TABLE crm.raw_pipelines (
    id TEXT PRIMARY KEY,
    payload JSONB NOT NULL,
    synced_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
);

COMMENT ON TABLE crm.raw_pipelines IS 'Raw RD Station pipelines payloads.';

CREATE INDEX raw_pipelines_payload_gin_idx ON crm.raw_pipelines USING GIN (payload);
CREATE INDEX raw_pipelines_updated_at_idx ON crm.raw_pipelines (updated_at);

CREATE TABLE crm.raw_pipeline_stages (
    id TEXT PRIMARY KEY,
    payload JSONB NOT NULL,
    synced_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ,
    pipeline_id TEXT
);

COMMENT ON TABLE crm.raw_pipeline_stages IS 'Raw RD Station pipeline stages payloads with extracted pipeline reference.';

CREATE INDEX raw_pipeline_stages_payload_gin_idx ON crm.raw_pipeline_stages USING GIN (payload);
CREATE INDEX raw_pipeline_stages_pipeline_id_idx ON crm.raw_pipeline_stages (pipeline_id);
CREATE INDEX raw_pipeline_stages_updated_at_idx ON crm.raw_pipeline_stages (updated_at);

CREATE TABLE crm.raw_users (
    id TEXT PRIMARY KEY,
    payload JSONB NOT NULL,
    synced_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
);

COMMENT ON TABLE crm.raw_users IS 'Raw RD Station users payloads.';

CREATE INDEX raw_users_payload_gin_idx ON crm.raw_users USING GIN (payload);
CREATE INDEX raw_users_updated_at_idx ON crm.raw_users (updated_at);

CREATE TABLE crm.raw_products (
    id TEXT PRIMARY KEY,
    payload JSONB NOT NULL,
    synced_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
);

COMMENT ON TABLE crm.raw_products IS 'Raw RD Station products payloads.';

CREATE INDEX raw_products_payload_gin_idx ON crm.raw_products USING GIN (payload);
CREATE INDEX raw_products_updated_at_idx ON crm.raw_products (updated_at);

CREATE TABLE crm.raw_deal_products (
    id TEXT PRIMARY KEY,
    payload JSONB NOT NULL,
    synced_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ,
    deal_id TEXT,
    product_id TEXT
);

COMMENT ON TABLE crm.raw_deal_products IS 'Raw RD Station deal-product association payloads with extracted join keys.';

CREATE INDEX raw_deal_products_payload_gin_idx ON crm.raw_deal_products USING GIN (payload);
CREATE INDEX raw_deal_products_deal_id_idx ON crm.raw_deal_products (deal_id);
CREATE INDEX raw_deal_products_product_id_idx ON crm.raw_deal_products (product_id);
CREATE INDEX raw_deal_products_updated_at_idx ON crm.raw_deal_products (updated_at);

COMMIT;
