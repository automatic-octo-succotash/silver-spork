BEGIN;

CREATE TABLE crm.sync_log (
    id BIGSERIAL PRIMARY KEY,
    source TEXT NOT NULL,
    last_synced_at TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL,
    error_message TEXT
);

COMMENT ON TABLE crm.sync_log IS 'Operational metadata for ingestion runs and sync checkpoints.';

CREATE INDEX sync_log_source_idx ON crm.sync_log (source);
CREATE INDEX sync_log_last_synced_at_idx ON crm.sync_log (last_synced_at);
CREATE INDEX sync_log_status_idx ON crm.sync_log (status);

COMMIT;
