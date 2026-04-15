ALTER TABLE crm.deals
    DROP COLUMN IF EXISTS organization_id,
    DROP COLUMN IF EXISTS campaign_id,
    DROP COLUMN IF EXISTS source_id;

DROP TABLE IF EXISTS crm.deal_contacts;
DROP TABLE IF EXISTS crm.contacts;
DROP TABLE IF EXISTS crm.raw_contacts;
DROP TABLE IF EXISTS crm.organizations;
DROP TABLE IF EXISTS crm.raw_organizations;
DROP TABLE IF EXISTS crm.campaigns;
DROP TABLE IF EXISTS crm.raw_campaigns;
DROP TABLE IF EXISTS crm.sources;
DROP TABLE IF EXISTS crm.raw_sources;
