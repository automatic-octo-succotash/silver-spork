ALTER TABLE crm.pipelines ADD COLUMN position INTEGER NOT NULL DEFAULT 0;

CREATE INDEX idx_pipelines_position ON crm.pipelines (position);
