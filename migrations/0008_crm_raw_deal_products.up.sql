CREATE TABLE crm.raw_deal_products (
    deal_id   TEXT        PRIMARY KEY REFERENCES crm.raw_deals(id) ON DELETE CASCADE,
    payload   JSONB       NOT NULL DEFAULT '[]',
    synced_at TIMESTAMPTZ NOT NULL
);
