-- Replace the JSONB-payload design (migration 0008) with a simple
-- (deal_id, product_id) association table. Associations are now built
-- by querying /crm/v2/deals?product_ids={id} for each product.
DROP TABLE IF EXISTS crm.raw_deal_products;

CREATE TABLE crm.raw_deal_products (
    deal_id    TEXT        NOT NULL,
    product_id TEXT        NOT NULL,
    synced_at  TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (deal_id, product_id)
);
