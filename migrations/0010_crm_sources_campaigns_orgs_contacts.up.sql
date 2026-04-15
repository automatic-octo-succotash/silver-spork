-- ── Sources ───────────────────────────────────────────────────────────────────

CREATE TABLE crm.raw_sources (
    id        TEXT        PRIMARY KEY,
    payload   JSONB       NOT NULL,
    synced_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE crm.sources (
    id   TEXT PRIMARY KEY,
    name TEXT NOT NULL
);

-- ── Campaigns ─────────────────────────────────────────────────────────────────

CREATE TABLE crm.raw_campaigns (
    id        TEXT        PRIMARY KEY,
    payload   JSONB       NOT NULL,
    synced_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE crm.campaigns (
    id   TEXT PRIMARY KEY,
    name TEXT NOT NULL
);

-- ── Organizations ─────────────────────────────────────────────────────────────

CREATE TABLE crm.raw_organizations (
    id        TEXT        PRIMARY KEY,
    payload   JSONB       NOT NULL,
    synced_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE crm.organizations (
    id   TEXT PRIMARY KEY,
    name TEXT NOT NULL
);

-- ── Contacts ──────────────────────────────────────────────────────────────────

CREATE TABLE crm.raw_contacts (
    id        TEXT        PRIMARY KEY,
    payload   JSONB       NOT NULL,
    synced_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE crm.contacts (
    id   TEXT PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE crm.deal_contacts (
    deal_id    TEXT NOT NULL REFERENCES crm.deals(id)    ON DELETE RESTRICT,
    contact_id TEXT NOT NULL REFERENCES crm.contacts(id) ON DELETE RESTRICT,
    PRIMARY KEY (deal_id, contact_id)
);

CREATE INDEX idx_deal_contacts_contact_id ON crm.deal_contacts (contact_id);

-- ── Extend crm.deals ──────────────────────────────────────────────────────────

ALTER TABLE crm.deals
    ADD COLUMN source_id       TEXT REFERENCES crm.sources(id)       ON DELETE RESTRICT,
    ADD COLUMN campaign_id     TEXT REFERENCES crm.campaigns(id)      ON DELETE RESTRICT,
    ADD COLUMN organization_id TEXT REFERENCES crm.organizations(id)  ON DELETE RESTRICT;

CREATE INDEX idx_deals_source_id       ON crm.deals (source_id);
CREATE INDEX idx_deals_campaign_id     ON crm.deals (campaign_id);
CREATE INDEX idx_deals_organization_id ON crm.deals (organization_id);
