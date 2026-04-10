BEGIN;

-- Source-oriented schemas keep ingestion boundaries explicit and make it
-- straightforward to add future sources such as wms, tms, or erp later.
CREATE SCHEMA crm;
CREATE SCHEMA derived;

COMMENT ON SCHEMA crm IS 'RD Station CRM v2 ingestion and normalized relational model.';
COMMENT ON SCHEMA derived IS 'Cross-source and read-optimized analytical surfaces derived from normalized data.';

COMMIT;
